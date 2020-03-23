/*
 Scan and list found devices
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include <stdio.h>
//------------------------------------------------------------------------------
CBUUID *serviceUuid;
CBUUID *characteristicUuid;
//------------------------------------------------------------------------------
@interface BluetoothDevicePrinter: NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    bool shouldScan;
    CBPeripheral *peripheral;
    //    NSString *manufacturer;
}
//------------------------------------------------------------------------------
@property (retain) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBCentralManager * manager;
@property (atomic) int count;
@property (nonatomic) dispatch_queue_t bleQueue;
@property (copy) NSString *manufacturer;

//------------------------------------------------------------------------------
//- (id)init;
- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
- (void)startScan;
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
#pragma mark Implementation
@implementation BluetoothDevicePrinter
//------------------------------------------------------------------------------
@synthesize discoveredPeripherals;
//------------------------------------------------------------------------------
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.discoveredPeripherals = [NSMutableArray array];
        _count=0;
        shouldScan = true;
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue: nil];
    }
    return self;
}
//------------------------------------------------------------------------------
- (instancetype)initWithQueue
{
    self = [super init];
    if (self)
    {
        self.discoveredPeripherals = [NSMutableArray array];
        _count=0;
        shouldScan = true;
        _bleQueue = dispatch_queue_create("my_ble_device_list", DISPATCH_QUEUE_SERIAL);
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue: _bleQueue];
    }
    return self;
}
//------------------------------------------------------------------------------
- (void)dealloc
{
    [_manager stopScan];
    //    [_manager dealloc]
}

//------------------------------------------------------------------------------
#pragma mark Manager Methods

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"discoveredPeripherals"];
    const char* deviceName = [[aPeripheral name] cStringUsingEncoding:NSASCIIStringEncoding];
    if (deviceName)
        printf("New Device: %s\n", deviceName);
    
    if ([[aPeripheral name] isEqualToString: @"Time"])
    {
        NSLog(@"aPeripheral.identifier: %@", aPeripheral.identifier);
        printf("Found Time\n");
        [_manager stopScan];
        peripheral = aPeripheral;
        [_manager connectPeripheral:peripheral options:nil];
    }
    
    if( ![self.discoveredPeripherals containsObject:aPeripheral] )
    {
        const char* deviceName = [[aPeripheral name] cStringUsingEncoding:NSASCIIStringEncoding];
        if (deviceName)
            printf("New Device: %s\n", deviceName);
        else
            printf("No Name Device\n");
        
        [peripherals addObject:aPeripheral];
        
        //        NSUInteger anIndex = 0;
        //        [_manager stopScan];
        //        peripheral = [self.discoveredPeripherals objectAtIndex:anIndex];
        ////        [peripheral retain];
        //        [_manager connectPeripheral:peripheral options:nil];
    }
}
//------------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    printf("didConnectPeripheral\n");
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
    
    //    self.connected = @"Connected";
    
}
//------------------------------------------------------------------------------
- (void)centralManagerDidUpdateState:(CBCentralManager *)manager
{
    printf("state change\n");
    if ([manager state] == CBManagerStatePoweredOn && shouldScan)
    {
        [self startScan];
    }
}
//------------------------------------------------------------------------------
// Invoked whenever an existing connection with the peripheral is torn down.
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    printf("didDisconnectPeripheral\n");
}
//------------------------------------------------------------------------------
/// Invoked whenever the central manager fails to create a connection with the peripheral.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
}
//------------------------------------------------------------------------------
- (void) startScan
{
    printf("Start scanning\n");
    //    [_manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:myServiceUuid]] options:nil];
    [_manager scanForPeripheralsWithServices:nil options:nil];
}

//------------------------------------------------------------------------------
#pragma mark Peripheral Methods

// Invoked upon completion of a -[discoverServices:] request.
// Discover available characteristics on interested services
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    printf("didDiscoverServices\n");
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        [aPeripheral discoverCharacteristics:nil forService:aService];
        /* Service To Search For */
        //        if ([aService.UUID isEqual:serviceUuid])
        //        {
        //            [aPeripheral discoverCharacteristics:nil forService:aService];
        //        }
        //        /* Device Information Service */
        //        else if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"180A"]])
        //        {
        //            [aPeripheral discoverCharacteristics:nil forService:aService];
        //        }
        //
        //        /* GAP (Generic Access Profile) for Device Name */
        //        else if ( [aService.UUID isEqual:[CBUUID UUIDWithString:@"1800"]] )
        //        {
        //            [aPeripheral discoverCharacteristics:nil forService:aService];
        //        }
        
    }
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[discoverCharacteristics:forService:] request.
// Perform appropriate operations on interested characteristics
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    printf("didDiscoverCharacteristicsForService\n");
    //    if ([service.UUID isEqual:serviceUuid])
    //       {
    for (CBCharacteristic *aChar in service.characteristics)
    {
        /* Set notification on heart rate measurement */
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:aChar];
            NSLog(@"Found a Heart Rate Measurement Characteristic");
        }
        /* Read body sensor location */
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A38"]])
        {
            [aPeripheral readValueForCharacteristic:aChar];
            NSLog(@"Found a Body Sensor Location Characteristic");
        }
        /* Write heart rate control point */
        else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A39"]])
        {
            uint8_t val = 1;
            NSData* valData = [NSData dataWithBytes:(void*)&val length:sizeof(val)];
            [aPeripheral writeValue:valData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
        else
        {
            NSLog(@"Service: %@ with Char: %@", [aChar service].UUID, aChar.UUID);
            
            if (aChar.properties & CBCharacteristicPropertyRead)
            {
                [aPeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:characteristicUuid])
    {
        [self printCharacteristicData:characteristic];
    }
}

- (void) printCharacteristicData: (CBCharacteristic *)characteristic
{
    NSLog(@"Read Characteristics: %@", characteristic.UUID);
    NSData * updatedValue = characteristic.value;
    NSLog(@"%@: %@",updatedValue, [characteristic debugDescription]);
    printf("%s\n",(char*)updatedValue.bytes);
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
int main(int argc, const char * argv[])
{
    serviceUuid        = [CBUUID UUIDWithString:@"29D7544B-6870-45A4-BB7E-D981535F4525"]; // Generated with uuidgen
    characteristicUuid = [CBUUID UUIDWithString:@"B81672D5-396B-4803-82C2-029D34319015"];
    [BluetoothDevicePrinter new];
    CFRunLoopRun();
    return 0;
}
