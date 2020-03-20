/*
    Run your device as a peripheral
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MyPeripheralManagerDelegate: NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, assign) CBPeripheralManager* peripheralManager;
@property (nonatomic) CBPeripheralManagerConnectionLatency nextLatency;
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
+ (CBUUID*)LatencyCharacteristicUuid
{
    return [CBUUID UUIDWithString:@"B81672D5-396B-4803-82C2-029D34319015"]; // Generated with uuidgen
}
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"CBPeripheralManager entered state %@", [MyPeripheralManagerDelegate stringFromCBManagerState:peripheral.state]);
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        NSDictionary* dict = @{CBAdvertisementDataLocalNameKey: @"ConnLatencyTest"};
        
        CBUUID *serviceUuid = [CBUUID UUIDWithString:@"180D"]; // Heart Rate
//      CBUUID *serviceUuid = [CBUUID UUIDWithString:@"7AE48DEE-2597-4B4D-904E-A3E8C7735738"]; // Generated with uuidgen
        CBMutableService* service = [[CBMutableService alloc] initWithType:serviceUuid primary:TRUE];
        
        CBMutableCharacteristic* latencyCharacteristic = [[CBMutableCharacteristic alloc]  initWithType:MyPeripheralManagerDelegate.LatencyCharacteristicUuid properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable]; // value:nil makes it a dynamic-valued characteristic
        
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
+ (CBPeripheralManagerConnectionLatency) nextLatencyAfter:(CBPeripheralManagerConnectionLatency)latency {
    switch (latency) {
        case CBPeripheralManagerConnectionLatencyLow: return CBPeripheralManagerConnectionLatencyMedium;
        case CBPeripheralManagerConnectionLatencyMedium: return CBPeripheralManagerConnectionLatencyHigh;
        case CBPeripheralManagerConnectionLatencyHigh: return CBPeripheralManagerConnectionLatencyLow;
    }
}
+ (NSString*)describeLatency:(CBPeripheralManagerConnectionLatency)latency {
    switch (latency) {
        case CBPeripheralManagerConnectionLatencyLow: return @"Low";
        case CBPeripheralManagerConnectionLatencyMedium: return @"Medium";
        case CBPeripheralManagerConnectionLatencyHigh: return @"High";
    }
}
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request {
    if ([request.characteristic.UUID isEqualTo:MyPeripheralManagerDelegate.LatencyCharacteristicUuid]) {
        [self.peripheralManager setDesiredConnectionLatency:self.nextLatency forCentral:request.central];
        NSString* description = [MyPeripheralManagerDelegate describeLatency: self.nextLatency];
        request.value = [description dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheralManager respondToRequest:request withResult:CBATTErrorSuccess];
        NSLog(@"didReceiveReadRequest:latencyCharacteristic. Responding with %@", description);
        self.nextLatency = [MyPeripheralManagerDelegate nextLatencyAfter:self.nextLatency];
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
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
