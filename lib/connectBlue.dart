import 'dart:async';

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

  @override
  void initState() {
    super.initState();
    iniciarEscaneo();
  }

  void iniciarEscaneo() async {
    scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
      for (ScanResult result in results) {
        print('Escanenado');
        if (result.device.name == 'ESP32LF') {
          try {
            scanSubscription?.cancel();
            await FlutterBluePlus.stopScan();
            device = result.device;
            // Call connect() only once
            await device?.connect();
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
      withNames: ["ESP32LF"],
      timeout: Duration(seconds: 30),
    );
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