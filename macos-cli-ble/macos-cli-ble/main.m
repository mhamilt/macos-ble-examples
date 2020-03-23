/*
 Run your device as a peripheral
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//------------------------------------------------------------------------------
CBUUID *serviceUuid;
CBUUID *characteristicUuid;
//------------------------------------------------------------------------------
@interface MyPeripheralManagerDelegate: NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, assign) CBPeripheralManager* peripheralManager;
@property (atomic, strong) CBCentral *currentCentral;
@property (atomic, strong) CBMutableCharacteristic *mainCharacteristic;
@end
//------------------------------------------------------------------------------
@implementation MyPeripheralManagerDelegate
+ (NSString*)stringFromCBManagerState:(CBManagerState)state
{
    switch (state)
    {
        case CBManagerStatePoweredOff: return @"PoweredOff";
        case CBManagerStatePoweredOn: return @"PoweredOn";
        case CBManagerStateResetting: return @"Resetting";
        case CBManagerStateUnauthorized: return @"Unauthorized";
        case CBManagerStateUnknown: return @"Unknown";
        case CBManagerStateUnsupported: return @"Unsupported";
    }
}
//------------------------------------------------------------------------------
#pragma mark CENTRAL FUNCTIONS
- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    _currentCentral = central;
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    _currentCentral = nil;
    
    printf("------------------LOST Subscription\n------------------ ");
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    printf("------------------Ready To Update\n------------------ ");
}
//------------------------------------------------------------------------------
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"CBPeripheralManager entered state %@", [MyPeripheralManagerDelegate stringFromCBManagerState:peripheral.state]);
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        NSDictionary* dict = @{
            CBAdvertisementDataLocalNameKey: @"BleServiceTest",
            //            CBAdvertisementDataSolicitedServiceUUIDsKey: @[serviceUuid],
            CBAdvertisementDataServiceUUIDsKey: @[serviceUuid]
        };
        
        CBMutableService* service = [[CBMutableService alloc] initWithType:serviceUuid primary:YES];
        
        _mainCharacteristic = [[CBMutableCharacteristic alloc]
                               initWithType:characteristicUuid
                               properties:(
                                           CBCharacteristicPropertyRead |
                                           CBCharacteristicPropertyNotify // needed for didSubscribeToCharacteristic
                                           )
                               value: nil
                               permissions:CBAttributePermissionsReadable];
        
        service.characteristics = @[_mainCharacteristic];
        [self.peripheralManager addService:service];
        [self.peripheralManager startAdvertising:dict];
        NSLog(@"startAdvertising. isAdvertising: %d", self.peripheralManager.isAdvertising);
    }
}
//------------------------------------------------------------------------------
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
    NSLog(@"peripheralManagerDidStartAdvertising %d", self.peripheralManager.isAdvertising);
}

//------------------------------------------------------------------------------
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    if ([request.characteristic.UUID isEqualTo:characteristicUuid])
    {
        [self.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow
                                                 forCentral:request.central];
        NSString* description = @"ABCD";
        request.value = [description dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        NSLog(@"didReceiveReadRequest:latencyCharacteristic. Responding with %@", description);
    }
    else
    {
        NSLog(@"didReceiveReadRequest: (unknown) %@", request);
    }
}

- (void)sendValue:(NSString *)data
{
    [self.peripheralManager updateValue:[data dataUsingEncoding:NSUTF8StringEncoding]
                      forCharacteristic:_mainCharacteristic
                   onSubscribedCentrals:@[_currentCentral]];
}
@end
//------------------------------------------------------------------------------
int main(int argc, const char * argv[])
{
    
    serviceUuid        = [CBUUID UUIDWithString:@"29D7544B-6870-45A4-BB7E-D981535F4525"]; // Generated with uuidgen
    characteristicUuid = [CBUUID UUIDWithString:@"B81672D5-396B-4803-82C2-029D34319015"];
    @autoreleasepool
    {
        MyPeripheralManagerDelegate *peripheralManagerDelegate = [[MyPeripheralManagerDelegate alloc] init];
        dispatch_queue_t ble_service = dispatch_queue_create("ble_test_service",  DISPATCH_QUEUE_SERIAL);
        CBPeripheralManager* peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:peripheralManagerDelegate queue:ble_service];
        peripheralManagerDelegate.peripheralManager = peripheralManager;
        while (![peripheralManagerDelegate currentCentral]);
        
        NSString *stringToSend = (argc > 1) ? [NSString stringWithUTF8String:argv[1]] : @"";
        [peripheralManagerDelegate sendValue:stringToSend];
        
    }
    return 0;
}
//------------------------------------------------------------------------------
