import 'dart:typed_data';

import '../helpers/hex_helpers.dart';

/// An abstract representation of a crypto signature,
/// associated with a specific signature scheme, e.g., Ed25519 or Secp256k1.
///
/// This class represents the product of signing a message directly from a
/// PrivateKey and can be verified against a CryptoPublicKey.
abstract class Signature {
  /// Converts the signature into raw bytes (Uint8List).
  Uint8List toUint8Array();

  /// Converts the signature into a hex string with a "0x" prefix.
  @override
  String toString() {
    final bytes = toUint8Array();
    return bytesToHex(bytes);
  }
}

/// An abstract representation of an account signature,
/// associated with a specific authentication scheme e.g., Ed25519 or SingleKey.
///
/// This is the product of signing a message through an account,
/// and can be verified against an AccountPublicKey.
abstract class AccountSignature {
  /// Converts the account signature into raw bytes (Uint8List).
  Uint8List toUint8Array();

  /// Converts the account signature into a hex string with a "0x" prefix.
  @override
  String toString() {
    final bytes = toUint8Array();
    return bytesToHex(bytes);
  }
}
