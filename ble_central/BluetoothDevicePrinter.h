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
#define DEBUG_MODE 0
//------------------------------------------------------------------------------

@interface BluetoothDevicePrinter: NSObject
<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    bool shouldScan;
    CBPeripheral *peripheral;
    CBUUID *serviceUuid;
    CBUUID *characteristicUuid;
    //    NSString *manufacturer;
}
//------------------------------------------------------------------------------
@property (retain) NSMutableArray *discoveredPeripherals;
@property (strong, nonatomic) CBCentralManager * manager;
@property (atomic) int count;
@property (nonatomic) dispatch_queue_t bleQueue;
//@property (nonatomic) CBUUID *serviceUuid;
//@property (nonatomic) CBUUID *characteristicUuid;
@property (copy) NSString *manufacturer;

//------------------------------------------------------------------------------
- (instancetype)init;
- (instancetype)initWithQueue: (dispatch_queue_t) centralDelegateQueue;
- (instancetype)initWithQueue: (dispatch_queue_t) centralDelegateQueue
                serviceToScan: (CBUUID *) scanServiceId
         characteristicToRead: (CBUUID *) characteristicId;
- (void)startScan;
//------------------------------------------------------------------------------
@end

#endif /* MacosBleCentral_h */
