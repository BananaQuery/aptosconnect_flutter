import 'dart:typed_data';

import '../helpers/hex_helpers.dart';
import 'authentication_key.dart';
import 'signature.dart';

/// Represents the arguments required to verify a digital signature.
class VerifySignatureArgs {
  final Uint8List message;
  final Signature signature;

  VerifySignatureArgs({
    required this.message,
    required this.signature,
  });
}

/// Represents an abstract public key.
/// This class provides a common interface for verifying signatures and retrieving public key information.
abstract class PublicKey {
  /// Verifies that the private key associated with this public key signed the message with the given signature.
  bool verifySignature(VerifySignatureArgs args);

  /// Converts the public key to a byte array.
  Uint8List toUint8Array() {
    return bcsToBytes();
  }

  /// Converts the public key to a hexadecimal string with a "0x" prefix.
  @override
  String toString() {
    final bytes = toUint8Array();
    return bytesToHex(bytes);
  }

  /// Abstract method for serializing the public key into BCS format.
  Uint8List bcsToBytes();
}

/// Represents an abstract account public key.
/// Provides an interface for deriving an authentication key.
abstract class AccountPublicKey extends PublicKey {
  /// Gets the authentication key associated with this public key.
  AuthenticationKey authKey();
}
