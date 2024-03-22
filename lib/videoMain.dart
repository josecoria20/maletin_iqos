import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:maletin_iqos/main.dart';
import 'package:video_player/video_player.dart';

class VideoMain extends StatefulWidget {
  final BluetoothDevice signalBlue;
  const VideoMain({ Key? key, required this.signalBlue}) : super(key: key);

  @override
  _VideoMainState createState() => _VideoMainState();
}

class _VideoMainState extends State<VideoMain> {
  late VideoPlayerController controller;
  late Future<void> initializeVideoPlayerFuture;
  late StreamSubscription<List<int>> _characteristicSubscription;
  late String currentVideoAsset;
  bool isPlayVidOne = false;
  bool isPlayVidTwo = false;

  @override
  void initState() {
    // Inicializa el controlador de video y carga el video desde la ruta de los assets
    controller = VideoPlayerController.asset('assets/video/8.mp4');
    initializeVideoPlayerFuture = controller.initialize().then((_) {
      controller.play();
      controller.setLooping(true);
    });
    _listenBluetooth();
    super.initState();
  }

  @override
  void dispose() {
    // Asegúrate de liberar los recursos del controlador de video cuando el widget se descarte
    controller.dispose();
    _characteristicSubscription.cancel();
    super.dispose();
  }


Future<void> _listenBluetooth() async {
  while (true) {
    await _readCharacteristic();
    await Future.delayed(const Duration(milliseconds: 1500 ));
  }
}

Future<void> _readCharacteristic() async {
  widget.signalBlue.connectionState.listen((state) {
    if (state == BluetoothConnectionState.connected) {
      widget.signalBlue.discoverServices().then((services) {
        for (var service in services) {
          if (service.uuid.toString() == '19b10000-e8f2-537e-4f6c-d104768a1214') {
            service.characteristics.forEach((characteristic) async {
              if (characteristic.uuid.toString() == '19b10001-e8f2-537e-4f6c-d104768a1214') {
                characteristic.setNotifyValue(true);
                final List<int> value = await characteristic.read();
                final receivedData = String.fromCharCodes(value);
                _handleReceivedData(receivedData);

              }
            });
          }
        }
      });
    }
  });
}

  void _handleReceivedData(String data) {
    print('Recibido $data');
    // Implementa tu lógica para manejar los datos recibidos
    if (data == "2") {
      if (isPlayVidOne == false){
        isPlayVidOne = true;
        setState(() {
          controller.dispose();
          controller = VideoPlayerController.asset('assets/video/9.mp4');
          initializeVideoPlayerFuture = controller.initialize().then((_) {
            controller.play();
          });
        });
        // Establecer un temporizador para cambiar el estado después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            // Cambiar el estado después de 2 segundos
            isPlayVidOne = false;
            isPlayVidTwo = false;
          });
        });
      }
      controller.addListener(() {
        if(controller.value.position == controller.value.duration) {
          controller.dispose();
          setState(() {
            controller = VideoPlayerController.asset('assets/video/8.mp4');
            initializeVideoPlayerFuture = controller.initialize().then((_) {
              controller.play();
              controller.setLooping(true);
            });
          });
        }
      });
      controller.removeListener(() { 
        setState(() {
        });
      });
    } else if (data == "3") {
      if (isPlayVidTwo == false){
        isPlayVidTwo = true;
        setState(() {
          controller.dispose();
          controller = VideoPlayerController.asset('assets/video/10.mp4');
          initializeVideoPlayerFuture = controller.initialize().then((_) {
            controller.play();
          });
        });
        // Establecer un temporizador para cambiar el estado después de 2 segundos
        Future.delayed(const Duration(seconds: 2), () {
          setState(() {
            // Cambiar el estado después de 2 segundos
            isPlayVidTwo = false;
            isPlayVidOne = false;
          });
        });
      }
      controller.addListener(() {
        if(controller.value.position == controller.value.duration) {
          controller.dispose();
          setState(() {
            controller = VideoPlayerController.asset('assets/video/8.mp4');
            initializeVideoPlayerFuture = controller.initialize().then((_) {
              controller.play();
              controller.setLooping(true);
            });
          });
        }
      });
      controller.removeListener(() { 
        setState(() {
        });
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: GestureDetector(
            // Agrega GestureDetector para detectar gestos en el widget VideoPlayer
            onLongPress: () async {
              // ignore: use_build_context_synchronously
              Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const Start(),
              ),
        (route) => false);
            },
            child: FutureBuilder(
              future: initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // Una vez que el controlador de video esté inicializado, muestra el video
                  return AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  );
                } else {
                  // Mientras se inicializa el controlador de video, muestra un indicador de carga
                  return const Center(
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
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

