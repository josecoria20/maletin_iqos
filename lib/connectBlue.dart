import 'dart:async';
import 'dart:io';

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
    isSupportedBLE();
    super.initState();
  }

  void isSupportedBLE() async {
    if (await FlutterBluePlus.isSupported == false) {
        print("Bluetooth not supported by this device");
        return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
        print(state);
        if (state == BluetoothAdapterState.on) {
            // usually start scanning, connecting, etc
            print('Se activo el Bluettoth');
            iniciarEscaneo();
        } else {
            // show an error to the user, etc
            print('No se pudo encender el Bluetoth');
        }
    });
    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
    }
  }

  void iniciarEscaneo() async {
    print('Empieza el scaneo');
    // listen to scan results
    // Note: `onScanResults` only returns live scan results, i.e. during scanning
    // Use: `scanResults` if you want live scan results *or* the results from a previous scan
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      print('Escaneos: $results');
            if (results.isNotEmpty) {
              for (ScanResult r in results){
                print('Results: ${r.device.advName}');
                if (r.device.advName == 'ESP32Serial') {
                    device = r.device;
                    _connectToDevice(r.device);
                    break;
                }
              }
            }
        },
        onError: (e) => print(e),
    );

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState.where((val) => val == BluetoothAdapterState.on).first;

    // Start scanning w/ timeout
    // Optional: you can use `stopScan()` as an alternative to using a timeout
    // Note: scan filters use an *or* behavior. i.e. if you set `withServices` & `withNames`
    //   we return all the advertisments that match any of the specified services *or* any
    //   of the specified names.
    await FlutterBluePlus.startScan(
      withServices:[Guid("180D")],
      withNames:["ESP32Serial"],
      timeout: Duration(seconds:15));

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  void _connectToDevice(BluetoothDevice d) async {
    await d.connect();
    print('Se conecto el dispositivo: ${device!.isConnected}');
    sendCharacters();
  }
  void sendCharacters() async {
    List<BluetoothService> services = await device!.discoverServices();
    services.forEach((service) async {
        var characteristics = service.characteristics;
        for(BluetoothCharacteristic c in characteristics) {
            if (c.properties.read) {
                List<int> value = await c.read();
                print(value);
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