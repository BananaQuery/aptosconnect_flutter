import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos/bcs/serializer.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../wallet/app_info.dart';
import '../wallet/connect_request.dart';
import '../wallet/connect_response.dart';

class ConnectWalletScreen extends StatefulWidget {
  final String dappId;
  final DappInfo dappInfo;
  final String connectionProvider;

  const ConnectWalletScreen({
    super.key,
    required this.dappId,
    required this.dappInfo,
    this.connectionProvider = 'google',
  });

  @override
  ConnectWalletScreenState createState() => ConnectWalletScreenState();
}

class ConnectWalletScreenState extends State<ConnectWalletScreen> {
  static const String mockOpenerScript = """
    (function() {
      // Mock window.opener to simulate a parent window
      Object.defineProperty(window, 'opener', {
        value: {
          postMessage: function(message, targetOrigin) {
            // Log the message or pass it to Flutter (handled via JavaScriptChannel)
            FlutterChannel.postMessage(JSON.stringify(message));
          }
        },
        writable: false,
        configurable: false,
      });
    })();
  """;

  static const String postMessageScript = """
    let originalPostMessage = window.postMessage;
    window.postMessage = function(message, targetOrigin, transfer) {
      FlutterChannel.postMessage(message);
      originalPostMessage({ __messageType: 'PromptOpenerPingResponse'}, '\$url');
    };
  """;

  static const String connectionScheme = 'https';
  static const String connectionHost = 'aptosconnect.app';
  static const String connectionPath = '/prompt';
  static const int requestVersion = 4;

  late final WebViewController _controller;

  DappInfo get dappInfo => widget.dappInfo;
  String get connectionProvider => widget.connectionProvider;

  late Future<SimplePublicKey> publicKeyFuture;

  void _injectMockOpener() {
    _controller.runJavaScript(mockOpenerScript).then((value) {
      if (kDebugMode) {
        print('Injected mock window.opener successfully.');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error injecting mock window.opener: $error');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final algorithm = Ed25519();
    publicKeyFuture = algorithm.newKeyPair().then((keyPair) => keyPair.extractPublicKey());

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage jsMessage) {
          Map<String, dynamic> responseJson = jsonDecode(jsMessage.message);
          Uint8List buffer = Uint8List.fromList((responseJson['serializedValue']['data'] as Map).values.map<int>((e) => e).toList());
          Map<String, dynamic> response = ConnectResponse.deserialize(buffer);
        },
      )
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (e) async {
          _injectMockOpener();
        },
        onUrlChange: (UrlChange url) async {
          _injectMockOpener();
        },
        onPageFinished: (String url) async {
          // Handle when the page finishes loading here
          _injectMockOpener();
          await _controller.runJavaScript(postMessageScript);
          print(url);
        },
      ));
  }

  /// Encodes a wallet request into a URL-safe Base64 string.
  String urlEncodeWalletRequest({
    required String name,
    required Uint8List data,
    required int version,
  }) {
    final serializer = Serializer();

    // Serialize the request fields.
    serializer.serializeStr(name);
    serializer.serializeBytes(data);
    serializer.serializeStr(version.toString());

    // Convert the serialized data to a URL-safe Base64 string.
    return base64UrlEncode(serializer.getBytes());
  }

  String _buildConnectionUrl(SimplePublicKey publicKey) {
    ConnectRequestArgs args = ConnectRequestArgs(
      dappId: widget.dappId,
      dappEd25519PublicKeyB64: publicKey.toString(),
    );

    var s = serializeConnectRequest(DappInfo(domain: dappInfo.domain, name: dappInfo.name), args);

    var url = Uri(
      scheme: connectionScheme,
      host: connectionHost,
      path: connectionPath,
      queryParameters: {
        'request': urlEncodeWalletRequest(name: 'connect', data: s.data, version: requestVersion),
        'provider': connectionProvider,
      },
    );

    return url.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Connect Wallet")),
      body: FutureBuilder(
          future: publicKeyFuture,
          builder: (BuildContext context, AsyncSnapshot<SimplePublicKey> snapshot)  {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            _controller.loadRequest(Uri.parse(_buildConnectionUrl(snapshot.data!)));
            return WebViewWidget(controller: _controller);
          }
      )
    );
  }
}

class WalletResponseHandler {
  static Map<String, dynamic> deserializeResponse(String serializedResponse) {
    final decodedBytes = base64Url.decode(serializedResponse);
    final jsonResponse = utf8.decode(decodedBytes);
    return jsonDecode(jsonResponse);
  }
}