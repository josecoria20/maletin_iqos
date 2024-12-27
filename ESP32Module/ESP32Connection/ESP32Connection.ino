#include <ArduinoBLE.h> // Libreria de Bluetooth 5.0

#define L_BLE 2
int fsrAnalogPin1 = 32; // Pin para sensor 1
int fsrAnalogPin2 = 34; // Pin para sensor 2
int fsrReading1;
int fsrReading2;
String datosAEnviarFSR1 = "3"; // Datos a enviar para el sensor 1 (presionado)
String datosAEnviarFSR2 = "2"; // Datos a enviar para el sensor 2 (presionado)
String datosAEnviar0 = "0";    // Datos a enviar cuando no se cumple ninguna condición

bool sentFSR1 = false;
bool sentFSR2 = false;

unsigned long lastSendTime = 0;
unsigned long sendInterval = 2500; // Intervalo de tiempo en milisegundos

// Agregar la variable standbyMode
bool standbyMode = true;

// Bluetooth® Low Energy LED Service
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214");

// Bluetooth® Low Energy LED Switch Characteristic
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
  BLE.poll();  // Necesario para BLE

  // Leer valores de los sensores
  fsrReading1 = analogRead(fsrAnalogPin1);
  fsrReading2 = analogRead(fsrAnalogPin2);

  Serial.print("FSR1: ");
  Serial.println(fsrReading1);
  Serial.print("FSR2: ");
  Serial.println(fsrReading2);

  // Delimitar los valores de los sensores antes de enviar
  if (fsrReading2 >= 3000 && fsrReading2 <= 4095 && !sentFSR2) {
    switchCharacteristic.setValue(datosAEnviarFSR2.c_str());
    Serial.println("Enviado 3 para FSR2");
    sentFSR2 = true;
    lastSendTime = millis(); // Actualizar el tiempo del último envío
  } else if (fsrReading2 < 3000 || fsrReading2 > 4095) {
    sentFSR2 = false;
  }

  // Delimitar el rango del sensor 1
  if (fsrReading1 >= 3000 && fsrReading1 <= 4095 && !sentFSR1) {
    switchCharacteristic.setValue(datosAEnviarFSR1.c_str());
    Serial.println("Enviado 2 para FSR1");
    sentFSR1 = true;
    lastSendTime = millis(); // Actualizar el tiempo del último envío
  } else if (fsrReading1 < 3000 || fsrReading1 > 4095) {
    sentFSR1 = false;
  }

  // Verificar si ha pasado el tiempo suficiente desde el último envío
  if (millis() - lastSendTime >= sendInterval) {
    // Enviar 0 después del intervalo de tiempo especificado
    switchCharacteristic.setValue(datosAEnviar0.c_str());
    Serial.println("Enviado 0");
  }
}

// ************ HANDLERS BLE ************
void characteristicUpdatedHandler(BLEDevice central, BLECharacteristic characteristic) {
  payload = switchCharacteristic.value();
  Serial.println("Valor recibido: " + payload);

  if (payload.length() > 0) {
    Serial.println("Datos recibidos: " + payload);
    standbyMode = true;
    switchCharacteristic.setValue(payload);
  } else {
    Serial.println("Error: No se recibieron datos.");
  }
  standbyMode = true; // Volver al modo standby
}

void connectHandler(BLEDevice central) {
  Serial.print("Dispositivo BLE conectado, dirección: ");
  Serial.println(central.address());
  digitalWrite(L_BLE, HIGH);
}

void disconnectHandler(BLEDevice central) {
  digitalWrite(L_BLE, LOW);
}

// ************ FUNCIONES ************
// Inicializa el módulo BLE
void iniciarBLE() {
  if (!BLE.begin()) {
    Serial.println("Iniciación del módulo BLE fallida");
    while (1);
  }
  BLE.setLocalName("ESP32IQOS");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(switchCharacteristic);
  BLE.addService(ledService);

  BLE.setEventHandler(BLEConnected, connectHandler);
  BLE.setEventHandler(BLEDisconnected, disconnectHandler);

  switchCharacteristic.setEventHandler(BLEUpdated, characteristicUpdatedHandler);

  BLE.advertise();
  Serial.println("BLE LED Peripheral");
}
