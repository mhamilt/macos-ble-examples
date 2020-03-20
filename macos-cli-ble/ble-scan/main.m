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
}
//------------------------------------------------------------------------------
@property (strong, nonatomic) CBCentralManager * manager;
@property (atomic) int count;
@property (nonatomic) dispatch_queue_t bleQueue;
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

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"New Device: %@\n", [peripheral name]);
    printf("as c string %s\n", [[peripheral name] cStringUsingEncoding:NSASCIIStringEncoding]);
    _count++;
    
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
/// Reset local variables
/// @param central <#central description#>
/// @param aPeripheral <#aPeripheral description#>
/// @param error <#error description#>
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{

}
//------------------------------------------------------------------------------
/// Invoked whenever the central manager fails to create a connection with the peripheral.
/// @param central <#central description#>
/// @param aPeripheral <#aPeripheral description#>
/// @param error <#error description#>
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
}
//------------------------------------------------------------------------------
- (void) startScan
{
    printf("Start scanning\n");
    [_manager scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@"180D"]] options:nil];
}
//------------------------------------------------------------------------------
#pragma mark Peripheral Methods

/// Invoked upon completion of a -[discoverServices:] request.
/// Discover available characteristics on interested services
/// @param aPeripheral <#aPeripheral description#>
/// @param error <#error description#>
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    
}
//------------------------------------------------------------------------------

/// Invoked upon completion of a -[discoverCharacteristics:forService:] request.
/// Perform appropriate operations on interested characteristics
/// @param aPeripheral <#aPeripheral description#>
/// @param service <#service description#>
/// @param error <#error description#>
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
}
//------------------------------------------------------------------------------

/// Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
/// @param aPeripheral <#aPeripheral description#>
/// @param characteristic <#characteristic description#>
/// @param error <#error description#>
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
   
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
