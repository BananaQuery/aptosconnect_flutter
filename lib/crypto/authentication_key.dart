import 'dart:typed_data';
import 'package:aptos/aptos_types/account_address.dart';
import 'package:aptos/bcs/deserializer.dart';
import 'package:aptos/bcs/serializer.dart';
import 'package:aptosconnect_flutter/crypto/public_key.dart';

import 'package:crypto/crypto.dart' as crypto;
/// Different schemes for signing keys used in cryptographic operations.
enum SigningScheme {
  /// For Ed25519PublicKey
  Ed25519,

  /// For MultiEd25519PublicKey
  MultiEd25519,

  /// For SingleKey ecdsa
  SingleKey,

  /// For MultiKey
  MultiKey,
}

/// Maps SigningScheme to their respective integer values.
const Map<SigningScheme, int> signingSchemeValues = {
  SigningScheme.Ed25519: 0,
  SigningScheme.MultiEd25519: 1,
  SigningScheme.SingleKey: 2,
  SigningScheme.MultiKey: 3,
};

/// Maps SigningScheme to their respective integer values.
const Map<int, SigningScheme> valueToSigningScheme = {
  0: SigningScheme.Ed25519,
  1: SigningScheme.MultiEd25519,
  2: SigningScheme.SingleKey,
  3: SigningScheme.MultiKey,
};


/// Specifies the schemes for deriving account addresses from various data sources.
enum DeriveScheme {
  /// Derives an address using an AUID, used for objects
  DeriveAuid,

  /// Derives an address from another object address
  DeriveObjectAddressFromObject,

  /// Derives an address from a GUID, used for objects
  DeriveObjectAddressFromGuid,

  /// Derives an address from seed bytes, used for named objects
  DeriveObjectAddressFromSeed,

  /// Derives an address from seed bytes, used for resource accounts
  DeriveResourceAccountAddress,
}

/// Maps DeriveScheme to their respective integer values.
const Map<DeriveScheme, int> deriveSchemeValues = {
  DeriveScheme.DeriveAuid: 251,
  DeriveScheme.DeriveObjectAddressFromObject: 252,
  DeriveScheme.DeriveObjectAddressFromGuid: 253,
  DeriveScheme.DeriveObjectAddressFromSeed: 254,
  DeriveScheme.DeriveResourceAccountAddress: 255,
};


class AuthenticationKey {
  static const int LENGTH = 32; // Length of the Authentication Key
  final Uint8List data;

  /// Constructor to create an `AuthenticationKey` from raw data.
  AuthenticationKey(Uint8List data)
      : assert(data.length == LENGTH, 'Authentication Key length must be $LENGTH'),
        data = data;

  /// Serializes the authentication key into a fixed byte format.
  void serialize(Serializer serializer) {
    serializer.serializeFixedBytes(data);
  }

  /// Deserializes an `AuthenticationKey` from a byte stream.
  static AuthenticationKey deserialize(Deserializer deserializer) {
    final bytes = deserializer.deserializeFixedBytes(LENGTH);
    return AuthenticationKey(bytes);
  }

  /// Converts the internal representation to a `Uint8List`.
  Uint8List toUint8Array() {
    return data;
  }

  /// Generates an `AuthenticationKey` from a specified scheme and input bytes.
  static AuthenticationKey fromSchemeAndBytes({
    required Object scheme,
    required Uint8List input,
  }) {

    int schemeValue = 0;
    if (scheme is DeriveScheme) {
      assert (deriveSchemeValues.containsKey(scheme), 'Invalid DeriveScheme');
      schemeValue = deriveSchemeValues[scheme]!;
    }

    if (scheme is SigningScheme) {
      assert (signingSchemeValues.containsKey(scheme), 'Invalid SigningScheme');
      schemeValue = signingSchemeValues[scheme]!;
    }

    final hashInput = Uint8List(input.length + 1);
    hashInput.setAll(0, input);
    hashInput[input.length] = schemeValue; // Append scheme byte.

    // Convert the input data into a Digest.
    final sha3 = crypto.sha256.convert(hashInput);
    // Return the hash as a Uint8List.
    final hash = Uint8List.fromList(sha3.bytes);

    return AuthenticationKey(hash);
  }

  /// Derives an `AuthenticationKey` from a public key and a scheme.
  @Deprecated('Use `fromPublicKey` instead.')
  static AuthenticationKey fromPublicKeyAndScheme({
    required AccountPublicKey publicKey,
    required Object scheme,
  }) {
    return publicKey.authKey();
  }

  /// Converts a `PublicKey` to an `AuthenticationKey` using the derivation scheme inferred from the `PublicKey` instance.
  static AuthenticationKey fromPublicKey(AccountPublicKey publicKey) {
    return publicKey.authKey();
  }

  /// Derives an account address from an `AuthenticationKey`.
  AccountAddress derivedAddress() {
    return AccountAddress(data);
  }
}
