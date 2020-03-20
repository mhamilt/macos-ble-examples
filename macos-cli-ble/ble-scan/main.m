/*
 Scan and list found devices
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include <stdio.h>
//------------------------------------------------------------------------------
@interface BluetoothDevicePrinter: NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    bool shouldScan;
    CBPeripheral *peripheral;
    NSString *manufacturer;
}
//------------------------------------------------------------------------------
@property (retain) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBCentralManager * manager;
@property (atomic) int count;
@property (nonatomic) dispatch_queue_t bleQueue;
@property (copy) NSString *manufacturer;

//------------------------------------------------------------------------------
- (id)init;
- (void)setup;
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
- (void)setup
{
    _bleQueue = dispatch_queue_create("ble_device_list", NULL);
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue: _bleQueue];
}
//------------------------------------------------------------------------------
- (id)init
{
    _count=0;
    shouldScan = true;
    _bleQueue = dispatch_queue_create("ble_device_list", NULL);
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue: _bleQueue];
    return [BluetoothDevicePrinter alloc];
}

- (void)dealloc
{
    [_manager stopScan];
//    [_manager dealloc]
}

//------------------------------------------------------------------------------
#pragma mark Manager Methods

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSMutableArray *peripherals = [self mutableArrayValueForKey:@"heartRateMonitors"];
    if( ![self.discoveredPeripherals containsObject:aPeripheral] )
    {
        [peripherals addObject:aPeripheral];
        printf("New Device: %s\n",
               [[peripheral name] cStringUsingEncoding:NSASCIIStringEncoding]);
        NSUInteger anIndex = 0;
        [_manager stopScan];
        peripheral = [self.discoveredPeripherals objectAtIndex:anIndex];
//        [peripheral retain];
        [_manager connectPeripheral:peripheral options:nil];
    }
}
//------------------------------------------------------------------------------
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
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
/// Invoked whenever an existing connection with the peripheral is torn down.
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{

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
    [_manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"29D7544B-6870-45A4-BB7E-D981535F4525"]] options:nil];
}
//------------------------------------------------------------------------------
#pragma mark Peripheral Methods

/// Invoked upon completion of a -[discoverServices:] request.
/// Discover available characteristics on interested services
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[discoverCharacteristics:forService:] request.
// Perform appropriate operations on interested characteristics
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* Updated value for heart rate measurement received */
//    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]])
//    {
//        if( (characteristic.value)  || !error )
//        {
//            NSLog(characteristic.value);
//        }
//    }
    /* Value for body sensor location received */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2C7E85D8-E637-4518-AFF7-49D9E195FB1A"]])
    {
        NSData * updatedValue = characteristic.value;
        uint8_t* dataPointer = (uint8_t*)[updatedValue bytes];
                
        if(dataPointer)
        {
            for (int i = 0; i < [updatedValue length]; ++i)
            {
                printf("%d",dataPointer[i]);
            }
        }
    }
    /* Value for device Name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A00"]])
    {
        NSString * deviceName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Device Name = %@", deviceName);
    }
    /* Value for manufacturer name received */
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A29"]])
    {
        self.manufacturer = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        NSLog(@"Manufacturer Name = %@", self.manufacturer);
    }
}
//------------------------------------------------------------------------------

@end

BluetoothDevicePrinter *btPrinter;
void testMethod()
{
    btPrinter = [[BluetoothDevicePrinter alloc]init];
}


int getCount()
{
    return btPrinter.count;
}

int main(int argc, const char * argv[])
{
    testMethod();
//    dispatch_queue_t bleQueue = dispatch_queue_create("ble_device_list", NULL);
//    btPrinter.manager = [[CBCentralManager alloc]
//                         initWithDelegate:btPrinter
//                         queue: bleQueue];
    while(1);
    return 0;
}
