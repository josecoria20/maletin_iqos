// ************ LIBRERÍAS ************
#include <ArduinoBLE.h> //Libreria de Bluetoooth 5.0

#define L_BLE      2

// ************ CONSTANTES GLOBALES ************
bool standbyMode = true;

// Bluetooth® Low Energy LED Service
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214"); 

// Bluetooth® Low Energy LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEStringCharacteristic  switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, 23);

String payload = "";
// ************ SETUP ************
void setup() {
  pinMode(L_BLE, OUTPUT);
  Serial.begin(9600);
  iniciarBLE();  // Inicializamos Bluetooth BLE
}

// ************ LOOP ************
void loop() {
  BLE.poll();
  if (!standbyMode) {
    // Realizar alguna acción cuando no esté en modo standby
  }
}

// ************ HANDLERS BLE ************
void characteristicUpdatedHandler(BLEDevice central, BLECharacteristic characteristic){
  payload = switchCharacteristic.value();
  Serial.println(payload);

   // Enviar datos a Flutter
  int numeroAEnviar = 100000;
  //String datosAEnviar = "Datos desde el ESP32";
  String datosAEnviar = String(numeroAEnviar);
  switchCharacteristic.setValue(datosAEnviar.c_str()); 

  // Realizar alguna acción cuando se actualiza la característica BLE
  standbyMode = true; // Poner en standby mode nuevamente después de recibir una actualización
  Serial.print("Característica actualizada, valor recibido: ");
  Serial.println(switchCharacteristic.value());
}

void connectHandler(BLEDevice central) {
  Serial.print("Dispositivo BLE conectado, dirección: ");
  Serial.println(central.address());
  digitalWrite(L_BLE, HIGH);
}

void disconnectHandler(BLEDevice central) {
  // Realizar alguna acción cuando se desconecta un dispositivo BLE
  digitalWrite(L_BLE, LOW);
}

// ************ FUNCIONES ************
// Esta función realiza todas las configuraciones necesarias para inicializar el módulo BLE
void iniciarBLE() {
  // Iniciar inicialización
  if(!BLE.begin()){
    Serial.println("Iniciación del módulo BLE fallida");
    while(1);
  }
  BLE.setLocalName("Test2"); // Se le asigna un nombre al dispositivo periferico 
  BLE.setAdvertisedService(ledService); // Se le asignan los servicios correspondientes
  ledService.addCharacteristic(switchCharacteristic); // Agrega la característica al servicio
  BLE.addService(ledService); // Agregar el servicio

  // assign event handlers for connected, disconnected to peripheral
  BLE.setEventHandler(BLEConnected, connectHandler);
  BLE.setEventHandler(BLEDisconnected, disconnectHandler);
  
  // assign event handlers for characteristics:  
  switchCharacteristic.setEventHandler(BLEUpdated, characteristicUpdatedHandler);

  BLE.advertise(); // Inicia el Advertising
  Serial.println("BLE LED Peripheral"); // Se imprime en monitor la correcta inicializacion
}
