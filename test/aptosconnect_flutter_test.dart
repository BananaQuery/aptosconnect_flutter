import 'dart:typed_data';

import 'package:aptosconnect_flutter/wallet/connect_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test deserializer aptos connect response", () {
    Uint8List buffer = Uint8List.fromList([1, 201, 251, 41, 66, 129, 132, 211, 173, 250, 188, 15, 111, 103, 95, 12, 230, 51, 24, 215, 243, 102, 230, 207, 14, 35, 216, 84, 238, 36, 200, 165, 211, 2, 3, 27, 104, 116, 116, 112, 115, 58, 47, 47, 97, 99, 99, 111, 117, 110, 116, 115, 46, 103, 111, 111, 103, 108, 101, 46, 99, 111, 109, 32, 7, 223, 35, 154, 91, 198, 222, 231, 69, 82, 233, 150, 160, 198, 253, 73, 24, 169, 92, 68, 70, 201, 97, 63, 142, 82, 210, 211, 201, 97, 132, 10, 0, 0]);
    var deserializedResponse = ConnectResponse.deserialize(buffer);
    assert(deserializedResponse.isNotEmpty);
  });
}
