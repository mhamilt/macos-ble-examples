//
//  MacosBleCentral.h
//  macos-cli-ble
//
//  Created by mhamilt7 on 26/03/2020.
//  Copyright © 2020 mhamilt7. All rights reserved.
//

#ifndef MacosBleCentral_h
#define MacosBleCentral_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include <stdio.h>
//------------------------------------------------------------------------------

@interface BluetoothDevicePrinter: NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSMutableArray<CBPeripheral*> *discoveredPeripherals;
    NSTimer* readDataTimeout;
}
//------------------------------------------------------------------------------
@property (nonatomic, weak) CBCentralManager * manager;
//------------------------------------------------------------------------------
- (instancetype)init;
//------------------------------------------------------------------------------
@end

#endif /* MacosBleCentral_h */
