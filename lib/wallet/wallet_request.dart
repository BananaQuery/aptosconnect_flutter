import 'dart:typed_data';
import 'package:aptos/bcs/deserializer.dart';
import 'package:aptos/bcs/serializer.dart';

import 'app_info.dart';

typedef SerializeFn<T> = void Function(Serializer serializer, T value);
typedef DeserializeFn<T> = T Function(Deserializer deserializer);

class WalletRequest<RequestName, Version> {
  final DappInfo dappInfo;
  final RequestName name;
  final Version version;

  WalletRequest({
    required this.dappInfo,
    required this.name,
    required this.version,
  });
}

class WalletRequestWithArgs<RequestName, Version, TArgs>
    extends WalletRequest<RequestName, Version> {
  final TArgs args;

  WalletRequestWithArgs({
    required DappInfo dappInfo,
    required RequestName name,
    required Version version,
    required this.args,
  }) : super(dappInfo: dappInfo, name: name, version: version);
}

class SerializedWalletRequest<RequestName, Version> {
  final Uint8List data;
  final RequestName name;
  final Version version;

  SerializedWalletRequest({
    required this.data,
    required this.name,
    required this.version,
  });
}

SerializedWalletRequest<RequestName, Version>
serializeWalletRequest<RequestName, Version>(
    WalletRequest<RequestName, Version> request) {
  final serializer = Serializer();
  request.dappInfo.serializeDappInfo(serializer);
  final data = serializer.getBytes();
  return SerializedWalletRequest(
    data: data,
    name: request.name,
    version: request.version,
  );
}

WalletRequest<RequestName, Version>
deserializeWalletRequest<RequestName, Version>(
    SerializedWalletRequest<RequestName, Version> serialized) {
  final deserializer = Deserializer(serialized.data);
  final dappInfo = DappInfo.deserializeDappInfo(deserializer);
  return WalletRequest(
    dappInfo: dappInfo,
    name: serialized.name,
    version: serialized.version,
  );
}

SerializedWalletRequest<RequestName, Version>
serializeWalletRequestWithArgs<RequestName, Version, TArgs>(
    WalletRequestWithArgs<RequestName, Version, TArgs> request,
    SerializeFn<TArgs> serializeArgsFn) {
  final serializer = Serializer();

  request.dappInfo.serializeDappInfo(serializer);
  serializeArgsFn(serializer, request.args);
  final data = serializer.getBytes();

  return SerializedWalletRequest(
    data: data,
    name: request.name,
    version: request.version,
  );
}

WalletRequestWithArgs<RequestName, Version, TArgs>
deserializeWalletRequestWithArgs<RequestName, Version, TArgs>(
    SerializedWalletRequest<RequestName, Version> serialized,
    DeserializeFn<TArgs> deserializeArgsFn,
    ) {
  final deserializer = Deserializer(serialized.data);
  final dappInfo = DappInfo.deserializeDappInfo(deserializer);
  final args = deserializeArgsFn(deserializer);
  return WalletRequestWithArgs(
    dappInfo: dappInfo,
    name: serialized.name,
    version: serialized.version,
    args: args,
  );
}
