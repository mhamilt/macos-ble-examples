//------------------------------------------------------------------------------
#import "BluetoothDevicePrinter.h"
//------------------------------------------------------------------------------
///
@implementation BluetoothDevicePrinter
//------------------------------------------------------------------------------
@synthesize manager;
//------------------------------------------------------------------------------
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        discoveredPeripherals = [NSMutableArray array];
    }
    return self;
}

- (void)handleTimer:(NSTimer*)theTimer {
    NSArray* argv = (NSArray*) [theTimer userInfo];
    CBCentralManager* central = (CBCentralManager*)argv[0];
    CBPeripheral* aPeripheral = (CBPeripheral*)argv[1];
    switch(aPeripheral.state)
    {
        case CBPeripheralStateConnecting:
            NSLog(@"-------- Cancel Connection -----------");
            [central cancelPeripheralConnection: aPeripheral];
            break;
        default:
            if (readDataTimeout) {
                [readDataTimeout invalidate];
            }
            readDataTimeout = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                               target:self
                                                             selector:@selector(peripheralReadTimeout:)
                                                             userInfo:aPeripheral
                                                              repeats:NO];
            
            [theTimer invalidate];
            
            break;
    }
}

- (void)peripheralReadTimeout:(NSTimer*)theTimer 
{
    CBPeripheral* aPeripheral = (CBPeripheral*) [theTimer userInfo];
    
    @try {
        [manager cancelPeripheralConnection: aPeripheral];
    } @catch (NSException *exception) {
        NSLog(@"Error Disconnecting. Restart Scanning");
        [manager scanForPeripheralsWithServices:nil options:nil];
    }
    
}

//------------------------------------------------------------------------------
#pragma mark Manager Methods


- (void)centralManagerDidUpdateState:(CBCentralManager *)manager
{
    self.manager = manager;
    printf("%s\n", __PRETTY_FUNCTION__);
    if ([manager state] == CBManagerStatePoweredOn)
    {
        [manager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)aPeripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if (![discoveredPeripherals containsObject: aPeripheral])
    {
        [discoveredPeripherals addObject:aPeripheral];
        NSLog(@"Attempt Connection to %@", aPeripheral);
                
//        [central connectPeripheral:aPeripheral options:nil];
        [central connectPeripheral:aPeripheral options:@{
            CBConnectPeripheralOptionNotifyOnConnectionKey: @YES,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: @YES,
            CBConnectPeripheralOptionNotifyOnNotificationKey: @YES,
            //        CBConnectPeripheralOptionEnableTransportBridgingKey:,
            //        CBConnectPeripheralOptionRequiresANCS:,
            CBConnectPeripheralOptionStartDelayKey: @0
        }];
        [central stopScan];
        [NSTimer scheduledTimerWithTimeInterval:5.0
                                         target:self
                                       selector:@selector(handleTimer:)
                                       userInfo:@[central, aPeripheral]
                                        repeats:NO];
    }
}

//------------------------------------------------------------------------------

- (void) centralManager: (CBCentralManager *)central
   didConnectPeripheral: (CBPeripheral *)aPeripheral
{
    if (readDataTimeout) {
        [readDataTimeout invalidate];
    }
    readDataTimeout = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(peripheralReadTimeout:)
                                                     userInfo:aPeripheral
                                                      repeats:NO];
    
    printf("%s\n", __PRETTY_FUNCTION__);
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

//------------------------------------------------------------------------------
// Invoked whenever an existing connection with the peripheral is torn down.
- (void) centralManager: (CBCentralManager *)central
didDisconnectPeripheral: (CBPeripheral *)aPeripheral
                  error: (NSError *)error
{
    printf("%s\n", __PRETTY_FUNCTION__);
    [central scanForPeripheralsWithServices:nil options:nil];
}
//------------------------------------------------------------------------------
/// Invoked whenever the central manager fails to create a connection with the peripheral.
- (void) centralManager: (CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    NSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
}

//------------------------------------------------------------------------------
#pragma mark Peripheral Methods

// Invoked upon completion of a -[discoverServices:] request.
// Discover available characteristics on interested services
- (void) peripheral: (CBPeripheral *)aPeripheral
didDiscoverServices:(NSError *)error
{
    [readDataTimeout invalidate];
    readDataTimeout = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(peripheralReadTimeout:)
                                                     userInfo:aPeripheral
                                                      repeats:NO];
    
    NSLog(@"didDiscoverServices");
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"Service found with UUID: %@", aService.UUID);
        [aPeripheral discoverCharacteristics:nil
                                  forService:aService];
    }
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[discoverCharacteristics:forService:] request.
// Perform appropriate operations on interested characteristics
- (void) peripheral: (CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    [readDataTimeout invalidate];
    readDataTimeout = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(peripheralReadTimeout:)
                                                     userInfo:aPeripheral
                                                      repeats:NO];
    for (CBCharacteristic *aChar in service.characteristics)
    {
        NSLog(@"Service: %@ with Char: %@", [aChar service].UUID, aChar.UUID);
        if (aChar.properties & CBCharacteristicPropertyRead)
        {
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
            [aPeripheral readValueForCharacteristic:aChar];
        }
    }
}
//------------------------------------------------------------------------------

// Invoked upon completion of a -[readValueForCharacteristic:] request or on the reception of a notification/indication.
- (void) peripheral: (CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic 
              error:(NSError *)error
{
    printf("%s\n", __PRETTY_FUNCTION__);
    [readDataTimeout invalidate];
    readDataTimeout = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self
                                                     selector:@selector(peripheralReadTimeout:)
                                                     userInfo:aPeripheral
                                                      repeats:NO];
    [self printCharacteristicData: characteristic];
}

- (void) printCharacteristicData: (CBCharacteristic *)characteristic
{
    NSLog(@"Read Characteristics: %@", characteristic.UUID);
    NSLog(@"%@", [characteristic description]);

    NSData * updatedValue = characteristic.value;
    printf("%s\n",(char*)updatedValue.bytes);
}

- (void) peripheral: (CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBDescriptor *)descriptor error:(NSError *)error
{
    printf("%s\n", __PRETTY_FUNCTION__);
}

- (void)peripheral: (CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    printf("%s\n", __PRETTY_FUNCTION__);
}
- (void)peripheral: (CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    printf("%s\n", __PRETTY_FUNCTION__);
}
//------------------------------------------------------------------------------
@end
