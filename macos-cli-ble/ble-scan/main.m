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
    
    if ([[aPeripheral name] isEqualToString: @"Time"])// &&
//        [[aPeripheral identifier].UUIDString isEqualTo:@"2A26C838-7DA8-4F7E-BA97-5488D3C851E4"])
    {
        NSLog(@"aPeripheral.identifier: %@", [aPeripheral identifier]);
        [_manager stopScan];
        peripheral = aPeripheral;
        NSDictionary *connectOptions = @{
        CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
        CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
        CBConnectPeripheralOptionNotifyOnNotificationKey: @YES,
//        CBConnectPeripheralOptionEnableTransportBridgingKey:,
//        CBConnectPeripheralOptionRequiresANCS:,
        CBConnectPeripheralOptionStartDelayKey: @0
        };
        [_manager connectPeripheral:peripheral options:connectOptions];
    }
    
    [self addToPeripheralList:aPeripheral];
}
- (void) addToPeripheralList:(CBPeripheral *)aPeripheral
{
    if( ![self.discoveredPeripherals containsObject:aPeripheral] )
    {
        [self.discoveredPeripherals addObject:aPeripheral];
    }
}
//------------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    printf("didConnectPeripheral\n");
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %lu - %@", [peripherals count], peripherals);
    
    [_manager stopScan];
    
    /* If there are any known devices, automatically connect to it.*/
    if([peripherals count] >=1)
    {
        peripheral = [peripherals objectAtIndex:0];
        [_manager connectPeripheral:peripheral
                            options:nil];
    }
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
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"1807"]])
        {
            [aPeripheral discoverCharacteristics:@[[CBUUID UUIDWithString:@"2A11"]] forService:aService];
        }
    }
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[discoverCharacteristics:forService:] request.
// Perform appropriate operations on interested characteristics
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics)
    {
        NSLog(@"Service: %@ with Char: %@", [aChar service].UUID, aChar.UUID);
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"2A11"]])
        {
            if (aChar.properties & CBCharacteristicPropertyRead)
            {
                [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
//                [aPeripheral readValueForCharacteristic:aChar];
//                [aPeripheral readValueForDescriptor:nil]
            }
        }
    }
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
        [self printCharacteristicData:characteristic];
}

- (void) printCharacteristicData: (CBCharacteristic *)characteristic
{
    NSLog(@"Read Characteristics: %@", characteristic.UUID);
    NSData * updatedValue = characteristic.value;
    NSLog(@"%@", [characteristic description]);
    printf("%s\n",(char*)updatedValue.bytes);
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBDescriptor *)descriptor error:(NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
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
