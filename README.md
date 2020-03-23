# macos-ble-examples
Examples for Managing Client connections and creating a peripheral on macOS

## Introduction

[BLE Low Down](https://github.com/tigoe/BLEDocs/wiki/Introduction-to-Bluetooth-LE)

>## But I Really Want A Serial Port!
>
>Sorry, Bluetooth LE doesn't work that way. And once you get used to the publish and subscribe model, you probably won't miss the serial port. If you really have to make something like a serial port, you can create a virtual serial port service by writing an interface that wraps a notify characteristic in a byte buffer to "look like" a serial port. But that's more trouble than it's worth. You would also have to think about situations where bytes arrive out-of-order or there are missing bytes in the stream and handle them in a way that would not surprise users of serial ports.

[GATT Services](https://www.bluetooth.com/specifications/gatt/services/)
[GATT Characteristics](https://www.bluetooth.com/specifications/gatt/characteristics/)


Nordic BLE Uart is made up service, if using a microbit or Adafruit bluefruit, the service and characteristic UUIDs are
```
UART Service UUID: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
TX Characteristic UUID: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
RX Characteristic UUID: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
```
