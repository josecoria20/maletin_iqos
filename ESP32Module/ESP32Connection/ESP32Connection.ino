// ************ LIBRERÍAS ************////
#include <ArduinoBLE.h> //Libreria de Bluetoooth 5.0

#define L_BLE      2
int fsrAnalogPin1 = 32;
int fsrAnalogPin2 = 34;
int fsrReading1;
int fsrReading2;
String datosAEnviarFSR1 = "2";
String datosAEnviarFSR2 = "3";
String datosAEnviar0 = "0";

bool sentFSR1 = false;
bool sentFSR2 = false;

unsigned long lastSendTime = 0;
unsigned long sendInterval = 2500; // Intervalo de tiempo en milisegundos

// ************ CONSTANTES GLOBALES ************
bool standbyMode = true;

// Bluetooth® Low Energy LED Service
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214");

// Bluetooth® Low Energy LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEStringCharacteristic switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, 23);

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

  fsrReading1 = analogRead(fsrAnalogPin1);
  fsrReading2 = analogRead(fsrAnalogPin2);



  //Serial.print("FSR1: ");
  //Serial.println(fsrReading1);
  //Serial.print("FSR2: ");
  //Serial.println(fsrReading2);

  if (fsrReading2 <= 5 && !sentFSR2) {
    switchCharacteristic.setValue(datosAEnviarFSR2.c_str());
    Serial.println("-------------------------------------------------------------Enviado 3 para FSR2-------------------------------------------------------------");
    sentFSR2 = true;
    lastSendTime = millis(); // Actualizar el tiempo del último envío
  } else if (fsrReading2 > 5) {
    sentFSR2 = false;
  }
  
  // Verificar condiciones para enviar datos
  if (fsrReading1 <= 5 && !sentFSR1) {
    switchCharacteristic.setValue(datosAEnviarFSR1.c_str());
    Serial.println("-------------------------------------------------------------Enviado 2 para FSR1-------------------------------------------------------------");
    sentFSR1 = true;
    lastSendTime = millis(); // Actualizar el tiempo del último envío
  } else if (fsrReading1 > 5) {
    sentFSR1 = false;
  }

  // Verificar si ha pasado el tiempo suficiente desde el último envío
  if (millis() - lastSendTime >= sendInterval) {
    // Enviar 0 después del intervalo de tiempo especificado
    switchCharacteristic.setValue(datosAEnviar0.c_str());
    Serial.println("-------------------------------------------------------------Enviado 0-------------------------------------------------------------");
  }

}

// ************ HANDLERS BLE ************
  void characteristicUpdatedHandler(BLEDevice central, BLECharacteristic characteristic){
    payload = switchCharacteristic.value();
    Serial.println("Valor recibido: " + payload);  

    // Verificar si el valor recibido no está vacío
    if (payload.length() > 0) {
      // Realizar alguna acción basada en el valor recibido
      // Por ejemplo, enviar los datos recibidos directamente a través del monitor serial
      Serial.println("Datos recibidos: " + payload);

      // Poner en standby mode nuevamente después de recibir una actualización
      standbyMode = true;

      // Actualizar la característica BLE con los datos recibidos
      switchCharacteristic.setValue(payload);
    } else {
      // Si el valor recibido está vacío, imprimir un mensaje de error
      Serial.println("Error: No se recibieron datos.");
    }

    // Realizar alguna acción cuando se actualiza la característica BLE
    standbyMode = true; // Poner en standby mode nuevamente después de recibir una actualización
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
  BLE.setLocalName("ESP32IQOS"); // Se le asigna un nombre al dispositivo periferico 
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


