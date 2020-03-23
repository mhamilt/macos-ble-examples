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
@property (nonatomic) CBPeripheralManagerConnectionLatency nextLatency;
@property (nonatomic, strong) CBCentral *currentCentral;
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
- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    printf("------------------New Subscription\n------------------ ");
}
//------------------------------------------------------------------------------
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"CBPeripheralManager entered state %@", [MyPeripheralManagerDelegate stringFromCBManagerState:peripheral.state]);
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        NSDictionary* dict = @{
//                        CBAdvertisementDataLocalNameKey: @"BleServiceTest",
            //            CBAdvertisementDataSolicitedServiceUUIDsKey: @[serviceUuid],
            CBAdvertisementDataServiceUUIDsKey: @[serviceUuid]
        };
        
        CBMutableService* service = [[CBMutableService alloc] initWithType:serviceUuid primary:YES];
        
        CBMutableCharacteristic* characteristic = [[CBMutableCharacteristic alloc]
                                                          initWithType:characteristicUuid
                                                          properties:CBCharacteristicPropertyRead
                                                          value:nil
                                                          permissions:CBAttributePermissionsReadable];
        
        service.characteristics = @[characteristic];
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
        [self.peripheralManager setDesiredConnectionLatency:self.nextLatency forCentral:request.central];
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
@end
//------------------------------------------------------------------------------
int main(int argc, const char * argv[])
{
    serviceUuid        = [CBUUID UUIDWithString:@"29D7544B-6870-45A4-BB7E-D981535F4525"]; // Generated with uuidgen
    characteristicUuid = [CBUUID UUIDWithString:@"B81672D5-396B-4803-82C2-029D34319015"];
    @autoreleasepool
    {
        MyPeripheralManagerDelegate *peripheralManagerDelegate = [[MyPeripheralManagerDelegate alloc] init];
        CBPeripheralManager* peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:peripheralManagerDelegate queue:nil];
        peripheralManagerDelegate.peripheralManager = peripheralManager;
        CFRunLoopRun();
    }
    return 0;
}
//------------------------------------------------------------------------------
