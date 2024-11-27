import 'package:aptos/bcs/serializer.dart';

import 'app_info.dart';
import 'wallet_request.dart';

class ClaimOptions {
  final String? asset;
  // final Ed25519PrivateKey secretKey;
  final String network = "mainnet";

  ClaimOptions({
    this.asset,
    // required this.secretKey,
  });
}

class ConnectRequest extends WalletRequest<String, int> {
  final ConnectRequestArgs args;

  ConnectRequest({
    required DappInfo dappInfo,
    required int version,
    required this.args,
  }) : super(dappInfo: dappInfo, name: requestName, version: version);

  static const String requestName = "connect";
  static const List<int> supportedVersions = [1, 2, 3, 4];
  static const int currentVersion = 4;
}

class ConnectRequestArgs {
  final ClaimOptions? claimOptions;
  final String? dappEd25519PublicKeyB64;
  final String? dappId;
  final String? preferredWalletName;

  ConnectRequestArgs({
    this.claimOptions,
    this.dappEd25519PublicKeyB64,
    this.dappId,
    this.preferredWalletName,
  });
}

void serializeConnectRequestArgs(Serializer serializer, ConnectRequestArgs args) {
  if (args.dappId != null) {
    serializer.serializeBool(true);
    serializer.serializeStr(args.dappId!);
  } else {
    serializer.serializeBool(false);
  }

  if (args.dappEd25519PublicKeyB64 != null) {
    serializer.serializeBool(true);
    serializer.serializeStr(args.dappEd25519PublicKeyB64!);
  } else {
    serializer.serializeBool(false);
  }

  if (args.preferredWalletName != null) {
    serializer.serializeBool(true);
    serializer.serializeStr(args.preferredWalletName!);
  } else {
    serializer.serializeBool(false);
  }

  serializer.serializeBool(args.claimOptions != null);
  if (args.claimOptions != null) {
    final claimOptions = args.claimOptions!;
    // serializer.serialize(claimOptions.secretKey);
    serializer.serializeStr(claimOptions.network.toString());

    if (claimOptions.asset != null) {
      serializer.serializeBool(true);
      serializer.serializeStr(claimOptions.asset!);
    } else {
      serializer.serializeBool(false);
    }
  }
}

// ConnectRequestArgs deserializeConnectRequestArgs(
//     Deserializer deserializer, int version) {
//   if (version == 1) {
//     return ConnectRequestArgs();
//   }
//
//   final dappId = deserializer.deserializeOption<String>();
//   final dappEd25519PublicKeyB64 = deserializer.deserializeOption<String>();
//   final preferredWalletName =
//   version >= 3 ? deserializer.deserializeOption<String>() : null;
//
//   final hasClaimOptions = version >= 4 ? deserializer.deserializeBool() : false;
//   ClaimOptions? claimOptions;
//
//   if (hasClaimOptions) {
//     final secretKey = deserializer.deserialize<Ed25519PrivateKey>(
//             (d) => Ed25519PrivateKey.deserialize(d));
//     final network = deserializer.deserializeStr();
//     final asset = deserializer.deserializeOption<String>();
//
//     claimOptions = ClaimOptions(
//       asset: asset,
//       secretKey: secretKey,
//     );
//   }
//
//   return ConnectRequestArgs(
//     claimOptions: claimOptions,
//     dappEd25519PublicKeyB64: dappEd25519PublicKeyB64,
//     dappId: dappId,
//     preferredWalletName: preferredWalletName,
//   );
// }

SerializedWalletRequest<String, int> serializeConnectRequest(
    DappInfo dappInfo, ConnectRequestArgs args) {
  return serializeWalletRequestWithArgs(
    WalletRequestWithArgs(
      dappInfo: dappInfo,
      name: ConnectRequest.requestName,
      version: ConnectRequest.currentVersion,
      args: args,
    ),
    serializeConnectRequestArgs,
  );
}

// ConnectRequest deserializeConnectRequest(
//     SerializedWalletRequest<String, int> request) {
//   final args = deserializeWalletRequestWithArgs(
//     request,
//         (d) => deserializeConnectRequestArgs(d, request.version),
//   );
//   return ConnectRequest(
//     dappInfo: args.dappInfo,
//     version: args.version,
//     args: args.args,
//   );
// }

bool isSerializedConnectRequest(
    SerializedWalletRequest request) {
  return request.name == ConnectRequest.requestName &&
      ConnectRequest.supportedVersions.contains(request.version);
}
