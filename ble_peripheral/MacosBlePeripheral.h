//
//  MacosBlePeripheral.h
//  macos-cli-ble
//
//  Created by mhamilt7 on 26/03/2020.
//  Copyright © 2020 mhamilt7. All rights reserved.
//

#ifndef MacosBlePeripheral_h
#define MacosBlePeripheral_h

/*
 Run your device as a peripheral
 */
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//------------------------------------------------------------------------------
#define DEBUG_MODE 0
#if DEBUG_MODE
#pragma message "hello"
#endif
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
@interface MyPeripheralManagerDelegate: NSObject<CBPeripheralManagerDelegate>
{
    CBUUID *serviceUuid;
    CBUUID *characteristicUuid;
}
@property (nonatomic, assign) CBPeripheralManager* peripheralManager;
@property (atomic, strong) CBCentral *currentCentral;
@property (atomic, strong) CBMutableCharacteristic *mainCharacteristic;
//------------------------------------------------------------------------------
- (void)initWithQueue;
- (void)sendValue:(NSString *)data;
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------

#endif /* MacosBlePeripheral_h */
