library bluetooth;

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

enum BluetoothSignal {
  good(0),
  normal(0, 0),
  weak(0, 0);

  final int min;
  final int max;

  const BluetoothSignal(this.min, [this.max = 256]);

  static BluetoothSignal find(int value) => BluetoothSignal.weak;
}

enum PrinterStatus {
  good(0),
  writeFailed(0),
  paperNotFound(0),
  tooHot(0),
  lowBattery(0),
  printing(0),
  unknown(0);

  final int priority;

  const PrinterStatus(this.priority);
}

enum PrinterDensity { normal, tight }

enum LogLevel { debug, info, warning, error }

enum BluetoothExceptionCode {
  timeout,
  deviceIsDisconnected,
  serviceNotFound,
  characteristicNotFound,
  adapterIsOff,
  connectionCanceled,
  userRejected,
}

enum BluetoothExceptionFrom { unknown }

class BluetoothOffException implements Exception {}

class BluetoothException implements Exception {
  final int code;
  final String? description;
  final BluetoothExceptionFrom? from;

  const BluetoothException({this.code = 0, this.description, this.from});
}

class Logger {
  static LogLevel level = LogLevel.info;
}

class Bluetooth {
  static Bluetooth i = Bluetooth();

  Stream<List<BluetoothDevice>> startScan() => Stream.empty();
  Future<BluetoothDevice> connect(String address) => Future.value(BluetoothDevice());
  Future<List<BluetoothDevice>> pairedDevices() => Future.value([]);
  Future<void> stopScan() => Future.value();
}

class BluetoothDevice {
  final Stream<bool> connectionState = Stream.empty();
  final bool connected = false;
  final String name = '';
  final int mtu = 0;
  final String address = '';

  BluetoothDevice();

  Future<void> connect() => Future.value();
  Future<void> disconnect() => Future.value();
  BluetoothService? getService(int id) => null;
  Stream<BluetoothSignal> createSignalStream({
    Duration interval = const Duration(minutes: 1),
  }) =>
      Stream.empty();
}

class BluetoothService {
  const BluetoothService();

  bool hasCharacteristic(int id) => false;
  BluetoothCharacteristic? getCharacteristic(int id) => null;
}

class BluetoothCharacteristic {
  const BluetoothCharacteristic();

  Future<bool> watch() => Future.value(false);
  Stream<Uint8List> read() => Stream.empty();
  Future<void> write(Uint8List data) => Future.value();
}

abstract class PrinterManufactory {
  final int serviceUuid;
  final int writerChar;
  final int readerChar;
  final int widthMM;
  final int widthBits;

  const PrinterManufactory({
    this.serviceUuid = 0,
    this.writerChar = 0,
    this.readerChar = 0,
    this.widthMM = 0,
    this.widthBits = 0,
  });

  Uint8List prepare() => Uint8List(0);
  Uint8List toCommands(Uint8List image, {required PrinterDensity density}) => Uint8List(0);
  Future<PrinterStatus> getStatus({
    required BluetoothCharacteristic writer,
    required BluetoothCharacteristic reader,
  }) =>
      Future.value(PrinterStatus.unknown);

  static PrinterManufactory? tryGuess(String name) => null;
}

class Printer extends ChangeNotifier {
  final String address;
  final PrinterManufactory manufactory;
  final bool connected = false;
  final Stream<PrinterStatus> statusStream = Stream.value(PrinterStatus.unknown);

  Printer({
    this.address = '',
    this.manufactory = const CatPrinter(),
    Printer? other,
  });

  Future<bool> connect() => Future.value(false);
  Future<void> disconnect() => Future.value();
  Stream<double> draw(
    Uint8List image, {
    PrinterDensity density = PrinterDensity.normal,
  }) =>
      Stream.empty();
}

class CatPrinter extends PrinterManufactory {
  const CatPrinter({int feedPaperByteSize = 0});
}

class XPrinter extends PrinterManufactory {
  const XPrinter({super.widthMM = 58, super.widthBits = 384});
}

class YokoscanPrinter extends PrinterManufactory {
  const YokoscanPrinter({required super.widthMM, required super.widthBits});
}
