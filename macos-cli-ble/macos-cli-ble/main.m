/*
    Run your device as a peripheral
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MyPeripheralManagerDelegate: NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, assign) CBPeripheralManager* peripheralManager;
@property (nonatomic) CBPeripheralManagerConnectionLatency nextLatency;
@property (nonatomic, strong) CBCentral *currentCentral;
@end

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
+ (CBUUID*)myUniqueCharacteristicUuid
{
    return [CBUUID UUIDWithString:@"2C7E85D8-E637-4518-AFF7-49D9E195FB1A"]; // Generated with uuidgen
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
//    currentCentral
    printf("------------------New Subscription\n------------------ ");
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"CBPeripheralManager entered state %@", [MyPeripheralManagerDelegate stringFromCBManagerState:peripheral.state]);
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        NSDictionary* dict = @{CBAdvertisementDataLocalNameKey: @"ConnLatencyTest"};
        
        CBUUID *serviceUuid = [CBUUID UUIDWithString:@"29D7544B-6870-45A4-BB7E-D981535F4525"]; // Generated with uuidgen
        CBMutableService* service = [[CBMutableService alloc] initWithType:serviceUuid primary:TRUE];
        
        CBMutableCharacteristic* latencyCharacteristic = [[CBMutableCharacteristic alloc]  initWithType:MyPeripheralManagerDelegate.myUniqueCharacteristicUuid properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable]; // value:nil makes it a dynamic-valued characteristic
        
        service.characteristics = @[latencyCharacteristic];
        [self.peripheralManager addService:service];
        [self.peripheralManager startAdvertising:dict];
        NSLog(@"startAdvertising. isAdvertising: %d", self.peripheralManager.isAdvertising);
    }
}
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral
                                       error:(NSError *)error
{

    if (error)
    {
        NSLog(@"Error advertising: %@", [error localizedDescription]);
    }
    NSLog(@"peripheralManagerDidStartAdvertising %d", self.peripheralManager.isAdvertising);

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if ([request.characteristic.UUID isEqualTo:MyPeripheralManagerDelegate.myUniqueCharacteristicUuid])
    {
        [self.peripheralManager setDesiredConnectionLatency:self.nextLatency forCentral:request.central];
        NSString* description = @"From Ble!";
        request.value = [description dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        NSLog(@"didReceiveReadRequest:latencyCharacteristic. Responding with %@", description);
    } else {
        NSLog(@"didReceiveReadRequest: (unknown) %@", request);
    }
}
@end

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        MyPeripheralManagerDelegate *peripheralManagerDelegate = [[MyPeripheralManagerDelegate alloc] init];
        CBPeripheralManager* peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:peripheralManagerDelegate queue:nil];
        peripheralManagerDelegate.peripheralManager = peripheralManager;
//        [peripheralManagerDelegate.peripheralManager setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyLow forCentral:<#(nonnull CBCentral *)#>]
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
