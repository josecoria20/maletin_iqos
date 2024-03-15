import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectBlue extends StatefulWidget {
  const ConnectBlue({ Key? key }) : super(key: key);

  @override
  State<ConnectBlue> createState() => _ConnectBlueState();
}

class _ConnectBlueState extends State<ConnectBlue> {
  StreamSubscription<List<ScanResult>>? scanSubscription;
  BluetoothDevice? device;
  String trama = '-1,2,200,255,70,4';

  @override
  void initState() {
    super.initState();
    iniciarEscaneo();
  }

  void iniciarEscaneo() async {
    scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
      for (ScanResult result in results) {
        print('Escanenado');
        if (result.device.advName == 'Test2') {
          try {
            scanSubscription?.cancel();
            await FlutterBluePlus.stopScan();
            device = result.device;
            // Call connect() only once
            await device?.connect();
            sendData();
            print('Conectado a ${device?.advName}');
            setState(() {}); // Trigger a UI update
            break;
          } catch (error) {
            print('Error connecting: $error');
            // Handle connection errors appropriately
          }
        }
      }
    });

    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;
    await FlutterBluePlus.startScan(
      withNames: ["Test2"],
      timeout: Duration(seconds: 30),
    );
  }
  void sendData() async {
    List<BluetoothService> services = await device!.discoverServices();
    services.forEach((service) async {
        // Reads all characteristics
      var characteristics = service.characteristics;
      for(BluetoothCharacteristic c in characteristics) {
          if (c.properties.read) {
              List<int> value = await c.read();
              final receivedData = String.fromCharCodes(value);
              print('Se recibio: $receivedData');
          }
      }
    });
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Conexión automática'),
        ),
        body: Center(
          child: Text(device != null ? 'Conectado a ${device?.advName}' : 'Buscando dispositivo...'),
        ),
      ),
    );
  }
}
