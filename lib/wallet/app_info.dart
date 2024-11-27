

import 'package:aptos/bcs/deserializer.dart';
import 'package:aptos/bcs/serializer.dart';

class DappInfo {
  final String domain;
  final String name;
  final String? imageURI;

  DappInfo({required this.domain, required this.name, this.imageURI});

  void serializeDappInfo(Serializer serializer) {
    serializer.serializeStr(domain);
    serializer.serializeStr(name);
    serializer.serializeBool(imageURI != null);
    if (imageURI != null) {
      serializer.serializeStr(imageURI!);
    }
  }

  static DappInfo deserializeDappInfo(Deserializer deserializer) {
    final domain = deserializer.deserializeStr();
    final name = deserializer.deserializeStr();
    final hasImageUri = deserializer.deserializeBool();
    final imageURI = hasImageUri ? deserializer.deserializeStr() : null;
    return DappInfo(domain: domain, name: name, imageURI: imageURI);
  }
}

