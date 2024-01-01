/*
 Scan and list found devices
 */
#import <Foundation/Foundation.h>
#import "BluetoothDevicePrinter.h"
//------------------------------------------------------------------------------
int main(int argc, const char * argv[])
{
    @autoreleasepool {
        dispatch_queue_t bleQueue;
        BluetoothDevicePrinter * blePrinter = [BluetoothDevicePrinter new];
        CBCentralManager* central = [[CBCentralManager alloc] initWithDelegate:blePrinter
                                                                         queue:bleQueue];        
        
        CFRunLoopRun();
    }
    return 0;
}

