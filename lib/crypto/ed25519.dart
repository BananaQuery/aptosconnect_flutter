import 'dart:typed_data';

import 'package:aptos/bcs/deserializer.dart';
import 'package:aptos/bcs/serializer.dart';
import 'package:aptosconnect_flutter/crypto/public_key.dart';

class Ed25519PublicKey extends PublicKey {
  static const LENGTH = 32;

  final Uint8List value;

  Ed25519PublicKey(this.value) {
    if (value.length != Ed25519PublicKey.LENGTH) {
      throw ArgumentError("Ed25519PublicKey length should be ${Ed25519PublicKey.LENGTH}");
    }
  }

  void serialize(Serializer serializer) {
    serializer.serializeBytes(value);
  }

  static Ed25519PublicKey deserialize(Deserializer deserializer) {
    Uint8List value = deserializer.deserializeBytes();
    return Ed25519PublicKey(value);
  }

  @override
  Uint8List bcsToBytes() {
    // TODO: implement bcsToBytes
    throw UnimplementedError();
  }

  @override
  bool verifySignature(VerifySignatureArgs args) {
    // TODO: implement verifySignature
    throw UnimplementedError();
  }
}

class Ed25519Signature {
  static const LENGTH = 64;

  final Uint8List value;

  Ed25519Signature(this.value) {
    if (value.length != Ed25519Signature.LENGTH) {
      throw ArgumentError("Ed25519Signature length should be ${Ed25519Signature.LENGTH}");
    }
  }

  void serialize(Serializer serializer) {
    serializer.serializeBytes(value);
  }

  static Ed25519Signature deserialize(Deserializer deserializer) {
    Uint8List value = deserializer.deserializeBytes();
    return Ed25519Signature(value);
  }
}