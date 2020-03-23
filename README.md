# macos-ble-examples

Simple CLI examples of using BLE and the CoreBluetooth framework in macOS.

## Targets

The xcode project contains multiple targets demonstrating a few different approaches to using BLE.

In most cases I am using a service and characteristic uuid generated with uuid gen.

```objc
serviceUuid        = [CBUUID UUIDWithString:@"29D7544B-6870-45A4-BB7E-D981535F4525"];
characteristicUuid = [CBUUID UUIDWithString:@"B81672D5-396B-4803-82C2-029D34319015"];
```

### `ble_peripheral`

This target builds a CLI app that will transmit the first argument as a string by updating a characteristic `B81672D5-396B-4803-82C2-029D34319015` after it has been subscribed to by another device.

### `ble_central`

This target is a CLI app that scans for peripherals advertising the service `29D7544B-6870-45A4-BB7E-D981535F4525`. It will connect to the first peripheral found, subscribe to the characteristic `B81672D5-396B-4803-82C2-029D34319015` and then exit when the peripheral shuts down.

## Resources About BLE

### [BLE Low Down](https://github.com/tigoe/BLEDocs/wiki/Introduction-to-Bluetooth-LE)

>#### But I Really Want A Serial Port!
>
>Sorry, Bluetooth LE doesn't work that way. And once you get used to the publish and subscribe model, you probably won't miss the serial port. If you really have to make something like a serial port, you can create a virtual serial port service by writing an interface that wraps a notify characteristic in a byte buffer to "look like" a serial port. But that's more trouble than it's worth. You would also have to think about situations where bytes arrive out-of-order or there are missing bytes in the stream and handle them in a way that would not surprise users of serial ports.

- [GATT Services](https://www.bluetooth.com/specifications/gatt/services/)
- [GATT Characteristics](https://www.bluetooth.com/specifications/gatt/characteristics/)


Nordic BLE UART is made up service, if using a microbit or Adafruit bluefruit, the service and characteristic UUIDs are:

```
UART Service UUID: 6E400001-B5A3-F393-E0A9-E50E24DCCA9E
TX Characteristic UUID: 6E400002-B5A3-F393-E0A9-E50E24DCCA9E
RX Characteristic UUID: 6E400003-B5A3-F393-E0A9-E50E24DCCA9E
```

**A device running iOS or macOS cannot run Nordic BLE UART as a peripheral.**
