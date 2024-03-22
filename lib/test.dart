import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:maletin_iqos/videoMain.dart';

class Test extends StatefulWidget {
  const Test({Key? key}) : super(key: key);

  @override
  State<Test> createState() => _ConnectBlueState();
}

class _ConnectBlueState extends State<Test> {
  StreamSubscription<List<ScanResult>>? scanSubscription;
  BluetoothDevice? device;

  @override
  void initState() {
    super.initState();
    //Se inicia con el método startScan
    _startScan();
  }

  void _startScan() async {
  scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
    for (ScanResult result in results) {
      //Los resultados del escaneo se filtran hasta encontrar el dispositivo
      if (result.device.advName == 'ESP32IQOS') {
        try {
          scanSubscription?.cancel();
          //Método para detener el escaneo
          await FlutterBluePlus.stopScan();
          //Se asigna a la variable local el dispositivo
          device = result.device;
          //Método para conectar el dispositivo
          await device!.connect();
          print('Conectado a ${device!.advName}');
          changeLayout(device!); // Aquí llamamos a la función para cambiar el layout
          break;
        } catch (error) {
          print('Error connecting: $error');
        }
      }
    }
  });
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;
  await FlutterBluePlus.startScan(
    withNames: ["ESP32IQOS"],
    timeout: const Duration(seconds: 30),
  );
}

  // void sendData() async {
  //   List<BluetoothService> services = await device.discoverServices();
  //   services.forEach((service) async {
  //     // Reads all characteristics
  //     var characteristics = service.characteristics;
  //     for (BluetoothCharacteristic c in characteristics) {
  //       if (c.properties.read) {
  //         List<int> value = await c.read();
  //         final receivedData = String.fromCharCodes(value);
  //         print('Se recibio: $receivedData');
  //         await c.write(utf8.encode(trama));
  //         print('se mando: ${utf8.encode(trama)}');
  //       }
  //     }
  //   });
  //}


  changeLayout(BluetoothDevice d){
    Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => VideoMain(signalBlue: d),
        ),
        (route) => false);
  }

  @override
  void dispose() {
    scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200, // Establece el tamaño deseado del CircularProgressIndicator
                height: 200, // Establece el tamaño deseado del CircularProgressIndicator
                child: CircularProgressIndicator(
                  strokeWidth: 15, // Ajusta el ancho del indicador circular
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A897)),
                ),
              ),
              SizedBox(height: 80),
              Text('Connecting...', style: TextStyle(color: Color(0xFF00A897), fontSize: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
