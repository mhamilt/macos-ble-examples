/*
 Scan and list found devices
 */
#import <Foundation/Foundation.h>
#import "BluetoothDevicePrinter.h"
//------------------------------------------------------------------------------
int main(int argc, const char * argv[])
{
    [BluetoothDevicePrinter new];
    CFRunLoopRun();
    return 0;
}
