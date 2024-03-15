import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maletin_iqos/connectBlue.dart';
import 'package:maletin_iqos/test.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(22, 114, 127, 1.0), // Color de la AppBar
      ),
      debugShowCheckedModeBanner: false , home: const Test(),
    );
  }
}