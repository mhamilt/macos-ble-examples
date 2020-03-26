//
//  MacosBleDevice.h
//  macos-cli-ble
//
//  Created by mhamilt7 on 26/03/2020.
//  Copyright © 2020 mhamilt7. All rights reserved.
//

#ifndef MacosBleDevice_h
#define MacosBleDevice_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include <stdio.h>
//------------------------------------------------------------------------------
#define DEBUG_MODE 0
//------------------------------------------------------------------------------
CBUUID *serviceUuid;
CBUUID *characteristicUuid;
//------------------------------------------------------------------------------
@interface MacosBleDevice: NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>
{
    bool shouldScan;
    CBPeripheral *peripheral;
    //    NSString *manufacturer;
}
//------------------------------------------------------------------------------
@property (retain) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBCentralManager * manager;
@property (atomic) int count;
@property (nonatomic) dispatch_queue_t bleQueue;
@property (copy) NSString *manufacturer;
//------------------------------------------------------------------------------
@property (nonatomic, assign) CBPeripheralManager* peripheralManager;
@property (atomic, strong) CBCentral *currentCentral;
@property (atomic, strong) CBMutableCharacteristic *mainCharacteristic;

//------------------------------------------------------------------------------
- (id)init;
//- (void)centralManagerDidUpdateState:(CBCentralManager *)central;
- (void)startScan;
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------

#endif /* MacosBleDevice_h */
