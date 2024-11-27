import 'dart:typed_data';

/// Converts a byte array (Uint8List) into a hexadecimal string with a "0x" prefix.
String bytesToHex(Uint8List bytes, {bool includePrefix = true}) {
  final hexString = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return includePrefix ? '0x$hexString' : hexString;
}

/// Converts a hexadecimal string to a byte array (Uint8List).
Uint8List hexToBytes(String hex) {
  if (hex.startsWith('0x')) {
    hex = hex.substring(2); // Remove the "0x" prefix if present.
  }

  if (hex.length % 2 != 0) {
    throw ArgumentError('Hex string must have an even number of characters');
  }

  final bytes = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < hex.length; i += 2) {
    final byteString = hex.substring(i, i + 2);
    final byte = int.parse(byteString, radix: 16);
    bytes[i ~/ 2] = byte;
  }
  return bytes;
}
