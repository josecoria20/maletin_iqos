import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _ConnectBlueState();
}

class _ConnectBlueState extends State<Test> {
  BluetoothDevice? targetDevice;
  BluetoothCharacteristic? targetCharacteristic;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  void _initBluetooth() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    FlutterBluePlus.onScanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.advName == 'ESP32LF') {
          targetDevice = result.device;
          _connectToDevice();
          break;
        }
      }
    });
  }

  void _connectToDevice() async {
    await targetDevice!.connect();
    List<BluetoothService> services = await targetDevice!.discoverServices();
    for (var service in services) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        c.write(utf8.encode('hola'));
        if (c.properties.read) {
          List<int> value = await c.read();
          String message = String.fromCharCodes(value);
          print('Valores recibidos: $message');
        }else{
          print('No envio nada');
        }
      }
      // for (var characteristic in service.characteristics) {
      //   targetCharacteristic = characteristic;
      //   characteristic.write(utf8.encode('H'));
      //   print('Se envio');
      //   _readFromDevice();
      // }
    }
  }

  void _readFromDevice() async {
    try {
      List<int> value = await targetCharacteristic!.read();
      String message = String.fromCharCodes(value);
      print("Received: $message");
    } catch (e) {
      print('Error during reading: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter BLE Example'),
      ),
      body: const Center(
        child: Text(
          'Hello ESP32!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

}
