import 'dart:convert';
import 'dart:typed_data';

import 'package:aptos/aptos_types/account_address.dart';
import 'package:aptos/bcs/deserializer.dart';
import 'package:aptos/bcs/serializer.dart';

import '../crypto/any_public_key.dart';
import '../crypto/authentication_key.dart';
import '../crypto/ed25519.dart';
import '../crypto/public_key.dart';

class ConnectResponse {
  static const supportedVersions = [1, 2];
  static const currentVersion = 2;

  // Serialize Approval Arguments for Version 1
  static void serializeApprovalArgsV1(Serializer serializer, Map<String, dynamic> value) {
    serializeAccountInfo(serializer, value['account']);
  }

  // Serialize Approval Arguments for Current Version
  static void serializeApprovalArgs(Serializer serializer, Map<String, dynamic> value) {
    serializeAccountInfo(serializer, value['account']);
    if (value['pairing'] != null) {
      serializer.serializeBool(true);
      serializer.serializeStr(jsonEncode(value['pairing']));
    } else {
      serializer.serializeBool(false);
    }
  }

  // Deserialize Approval Arguments
  static Map<String, dynamic> deserializeApprovalArgs(Deserializer deserializer) {
    final account = deserializeAccountInfo(deserializer);
    final serializedPairing = deserializer.deserializeStr();
    final pairing = serializedPairing != null && serializedPairing.isNotEmpty ? jsonDecode(serializedPairing) : null;
    return {
      'account': account,
      'pairing': pairing,
    };
  }

  // Serialize Function Handlers
  static final serializeArgsV1 = makeUserResponseSerializeFn(serializeApprovalArgsV1);
  static final serializeArgs = makeUserResponseSerializeFn(serializeApprovalArgs);

  // Deserialize Function Handler
  static final deserializeArgs = makeUserResponseDeserializeFn(deserializeApprovalArgs);

  // Serialize the Connect Response
  static String serialize(Map<String, dynamic> args, [int version = currentVersion]) {
    return serializeWalletResponse(
      args,
      version == 1 ? serializeArgsV1 : serializeArgs,
    );
  }

  // Deserialize the Connect Response
  static Map<String, dynamic> deserialize(Uint8List buffer) {
    return deserializeWalletResponse(buffer, deserializeArgs);
  }
}

// Supporting Classes and Methods

// Placeholder for Account Info Serialization/Deserialization
void serializeAccountInfo(Serializer serializer, Map<String, dynamic> account) {
  if (account['address'] != null && account['address'].isNotEmpty) {
    serializer.serializeBool(true);
    serializer.serializeStr(account['name']);
  } else {
    serializer.serializeBool(false);
  }
}

PublicKey deserializePublicKey(Deserializer deserializer) {
  final signingSchemeIndex = deserializer.deserializeUleb128AsU32();
  final signingScheme = valueToSigningScheme[signingSchemeIndex];

  switch (signingScheme) {
    case SigningScheme.Ed25519:
      return Ed25519PublicKey.deserialize(deserializer);
    // case SigningScheme.MultiEd25519:
    //   return deserializer.deserialize(() => MultiEd25519PublicKey());
    case SigningScheme.SingleKey:
      return AnyPublicKey.deserialize(deserializer);
    // case SigningScheme.MultiKey:
    //   return deserializer.deserialize(() => MultiKey());
    default:
      throw Exception("Unknown signing scheme: $signingScheme");
  }
}

Map<String, dynamic> deserializeAccountInfo(Deserializer deserializer) {
  AccountAddress address = AccountAddress.deserialize(deserializer);
  PublicKey publicKey = deserializePublicKey(deserializer);
  String name = deserializer.deserializeStr();
  return {
    'address': address,
    'publicKey': publicKey,
    if (name.isNotEmpty) 'name': name,
  };
}

// Make User Response Serialize Function
Function makeUserResponseSerializeFn(Function serializeArgsFn) {
  return (Serializer serializer, Map<String, dynamic> value) {
    if (value['status'] == 'approved') {
      serializer.serializeBool(true);
      serializer.serializeStr('approved');
    } else {
      serializer.serializeBool(false);
    }

    if (value['status'] == 'approved') {
      serializeArgsFn(serializer, value['args']);
    }
  };
}

// Make User Response Deserialize Function
Function makeUserResponseDeserializeFn(Function deserializeArgsFn) {
  return (Deserializer deserializer) {
    final isApproved = deserializer.deserializeBool();
    if (isApproved) {
      return {
        'status': 'approved',
        'args': deserializeArgsFn(deserializer),
      };
    } else {
      return {'status': 'dismissed'};
    }
  };
}

// Serialize Wallet Response
String serializeWalletResponse(Map<String, dynamic> args, Function serializeFn) {
  final serializer = Serializer();
  serializeFn(serializer, args);
  return serializer.toString();
}

// Deserialize Wallet Response
Map<String, dynamic> deserializeWalletResponse(Uint8List buffer, Function deserializeFn) {
  final deserializer = Deserializer(buffer);
  return deserializeFn(deserializer);
}
