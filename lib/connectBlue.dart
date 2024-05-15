import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:maletin_iqos/videoMain.dart';

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
    //Se inicia con el método startScan
    _startScan();
  }

  void _startScan() async {
  try {
    // Verificar si el adaptador Bluetooth está encendido
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    // Comenzar el escaneo de dispositivos con el nombre 'Test2'
    await FlutterBluePlus.startScan(
      withNames: ["ESP32IQOS"],
    );

    // Escuchar los resultados del escaneo
    scanSubscription = FlutterBluePlus.onScanResults.listen((results) async {
      for (ScanResult result in results) {
        // Los resultados del escaneo se filtran hasta encontrar el dispositivo
        if (result.device.advName == 'ESP32IQOS') {
          try {
            scanSubscription?.cancel();
            // Método para detener el escaneo
            await FlutterBluePlus.stopScan();
            // Se asigna a la variable local el dispositivo
            device = result.device;
            // Método para conectar el dispositivo
            await device!.connect();
            print('Conectado a ${device!.advName}');
            changeLayout(device!); // Aquí llamamos a la función para cambiar el layout
            _listenToDeviceState(); // Comenzar a escuchar el estado del dispositivo
            break;
          } catch (error) {
            print('Error connecting: $error');
          }
        }
      }
    });
  } catch (error) {
    print('Bluetooth adapter error: $error');
  }
}
void _listenToDeviceState() {
  device!.connectionState.listen((state) {
    if (state == BluetoothConnectionState.disconnected) {
      _reconnectToDevice();
    }
  });
}

void _reconnectToDevice() async {
  try {
    await device!.connect();
    print('Reconectado a ${device!.advName}');
  } catch (error) {
    print('Error reconnecting: $error');
  }
}


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
      debugShowCheckedModeBanner: false,
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
