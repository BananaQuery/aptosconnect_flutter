import 'dart:typed_data';

import 'package:aptos/aptos_types/account_address.dart';
import 'package:aptos/bcs/deserializer.dart';
import 'package:aptos/bcs/serializer.dart';
import 'package:aptosconnect_flutter/crypto/public_key.dart';
import 'ed25519.dart';

/// Represents different variants of public keys.
enum AnyPublicKeyVariant { Ed25519, Secp256k1, Keyless, FederatedKeyless }

Map<int, AnyPublicKeyVariant> valueToAnyPublicKeyVariant = {
  0: AnyPublicKeyVariant.Ed25519,
  1: AnyPublicKeyVariant.Secp256k1,
  3: AnyPublicKeyVariant.Keyless,
  4: AnyPublicKeyVariant.FederatedKeyless,
};

/// Represents different variants of signatures.
enum AnySignatureVariant { Ed25519, Secp256k1, Keyless }

/// Represents a signature.
abstract class Signature {
  Uint8List toUint8Array();

  void serialize(Serializer serializer);
}

/// Represents any public key supported by Aptos.
class AnyPublicKey extends PublicKey {
  final PublicKey publicKey;
  final AnyPublicKeyVariant variant;

  AnyPublicKey(this.publicKey)
      : variant = _determineVariant(publicKey);

  static AnyPublicKeyVariant _determineVariant(PublicKey publicKey) {
    if (publicKey is Ed25519PublicKey) {
      return AnyPublicKeyVariant.Ed25519;
    } else if (publicKey is Secp256k1PublicKey) {
      return AnyPublicKeyVariant.Secp256k1;
    } else if (publicKey is KeylessPublicKey) {
      return AnyPublicKeyVariant.Keyless;
    } else if (publicKey is FederatedKeylessPublicKey) {
      return AnyPublicKeyVariant.FederatedKeyless;
    } else {
      throw Exception("Unsupported public key type");
    }
  }

  @override
  Uint8List toUint8Array() {
    return publicKey.toUint8Array();
  }

  @override
  void serialize(Serializer serializer) {
    serializer.serializeU32AsUleb128(variant.index);
    // publicKey.serialize(serializer);
  }

  static AnyPublicKey deserialize(Deserializer deserializer) {
    final variantIndex = deserializer.deserializeUleb128AsU32();
    final variant = valueToAnyPublicKeyVariant[variantIndex];
    late PublicKey publicKey;

    switch (variant) {
      case AnyPublicKeyVariant.Ed25519:
        publicKey = Ed25519PublicKey.deserialize(deserializer);
        break;
      case AnyPublicKeyVariant.Secp256k1:
        publicKey = Secp256k1PublicKey.deserialize(deserializer);
        break;
      case AnyPublicKeyVariant.Keyless:
        publicKey = KeylessPublicKey.deserialize(deserializer);
        break;
      case AnyPublicKeyVariant.FederatedKeyless:
        publicKey = FederatedKeylessPublicKey.deserialize(deserializer);
        break;
      default:
        throw Exception("Unknown variant index for AnyPublicKey: $variantIndex");
    }

    return AnyPublicKey(publicKey);
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

/// Represents any signature supported by Aptos.
class AnySignature extends Signature {
  final Signature signature;
  final AnySignatureVariant variant;

  AnySignature(this.signature)
      : variant = _determineVariant(signature);

  static AnySignatureVariant _determineVariant(Signature signature) {
    if (signature is Ed25519Signature) {
      return AnySignatureVariant.Ed25519;
    } else if (signature is Secp256k1Signature) {
      return AnySignatureVariant.Secp256k1;
    } else if (signature is KeylessSignature) {
      return AnySignatureVariant.Keyless;
    } else {
      throw Exception("Unsupported signature type");
    }
  }

  @override
  Uint8List toUint8Array() {
    return signature.toUint8Array();
  }

  @override
  void serialize(Serializer serializer) {
    serializer.serializeU32AsUleb128(variant.index);
    signature.serialize(serializer);
  }

  static AnySignature deserialize(Deserializer deserializer) {
    final variantIndex = deserializer.deserializeUleb128AsU32();
    final variant = AnySignatureVariant.values[variantIndex];
    late Signature signature;

    switch (variant) {
      case AnySignatureVariant.Ed25519:
        signature = Ed25519Signature.deserialize(deserializer);
        break;
      case AnySignatureVariant.Secp256k1:
        signature = Secp256k1Signature.deserialize(deserializer);
        break;
      case AnySignatureVariant.Keyless:
        signature = KeylessSignature.deserialize(deserializer);
        break;
      default:
        throw Exception("Unknown variant index for AnySignature: $variantIndex");
    }

    return AnySignature(signature);
  }
}

class Secp256k1PublicKey extends PublicKey {
  @override
  Uint8List toUint8Array() => Uint8List(0);

  @override
  void serialize(Serializer serializer) {}

  static Secp256k1PublicKey deserialize(Deserializer deserializer) {
    return Secp256k1PublicKey();
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

class KeylessPublicKey extends PublicKey {

  KeylessPublicKey(this.iss, this.idCommitment) {
    if (idCommitment.length != KeylessPublicKey.ID_COMMITMENT_LENGTH) {
      throw Exception("Id Commitment length in bytes should be ${KeylessPublicKey.ID_COMMITMENT_LENGTH}");
    }
  }

  static int ID_COMMITMENT_LENGTH = 32;
  final String iss;
  final Uint8List idCommitment;

  @override
  Uint8List toUint8Array() => Uint8List(0);

  @override
  void serialize(Serializer serializer) {}

  static KeylessPublicKey deserialize(Deserializer deserializer) {
    String iss = deserializer.deserializeStr();
    Uint8List addressSeed = deserializer.deserializeBytes();
    return KeylessPublicKey(iss, addressSeed);
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

class FederatedKeylessPublicKey extends PublicKey {

  FederatedKeylessPublicKey(this.jwkAddress, this.keylessPublicKey);

  AccountAddress jwkAddress;
  KeylessPublicKey keylessPublicKey;

  @override
  Uint8List toUint8Array() => Uint8List(0);

  @override
  void serialize(Serializer serializer) {}

  static FederatedKeylessPublicKey deserialize(Deserializer deserializer) {
    AccountAddress jwkAddress = AccountAddress.deserialize(deserializer);
    KeylessPublicKey keylessPublicKey = KeylessPublicKey.deserialize(deserializer);
    return FederatedKeylessPublicKey(jwkAddress, keylessPublicKey);
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

// Placeholder classes for signatures
class Ed25519Signature extends Signature {
  @override
  Uint8List toUint8Array() => Uint8List(0);

  @override
  void serialize(Serializer serializer) {}

  static Ed25519Signature deserialize(Deserializer deserializer) {
    return Ed25519Signature();
  }
}

class Secp256k1Signature extends Signature {
  @override
  Uint8List toUint8Array() => Uint8List(0);

  @override
  void serialize(Serializer serializer) {}

  static Secp256k1Signature deserialize(Deserializer deserializer) {
    return Secp256k1Signature();
  }
}

class KeylessSignature extends Signature {
  @override
  Uint8List toUint8Array() => Uint8List(0);

  @override
  void serialize(Serializer serializer) {}

  static KeylessSignature deserialize(Deserializer deserializer) {
    return KeylessSignature();
  }
}
