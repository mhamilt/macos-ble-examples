#import "MacosBlePeripheral.h"
//------------------------------------------------------------------------------
@implementation MyPeripheralManagerDelegate
+ (NSString*)stringFromCBManagerState:(CBManagerState)state
{
    switch (state)
    {
        case CBManagerStatePoweredOff:   return @"PoweredOff";
        case CBManagerStatePoweredOn:    return @"PoweredOn";
        case CBManagerStateResetting:    return @"Resetting";
        case CBManagerStateUnauthorized: return @"Unauthorized";
        case CBManagerStateUnknown:      return @"Unknown";
        case CBManagerStateUnsupported:  return @"Unsupported";
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
}
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
#if DEBUG_MODE
    printf("------------------Ready To Update\n------------------ ");
#endif
}
//------------------------------------------------------------------------------
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
#if DEBUG_MODE
    NSLog(@"CBPeripheralManager entered state %@", [MyPeripheralManagerDelegate stringFromCBManagerState:peripheral.state]);
#endif
    if (peripheral.state == CBManagerStatePoweredOn)
    {
        NSDictionary* dict = @{
//            CBAdvertisementDataLocalNameKey: @"BleServiceTest",
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
#if DEBUG_MODE
        NSLog(@"startAdvertising. isAdvertising: %d", self.peripheralManager.isAdvertising);
#endif
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
#if DEBUG_MODE
    NSLog(@"peripheralManagerDidStartAdvertising %d", self.peripheralManager.isAdvertising);
#endif
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
#if DEBUG_MODE
        NSLog(@"didReceiveReadRequest:latencyCharacteristic. Responding with %@", description);
#endif
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
