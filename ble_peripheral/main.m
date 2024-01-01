#import <Foundation/Foundation.h>
#import "MyPeripheralManagerDelegate.h"
//------------------------------------------------------------------------------
int main(int argc, const char * argv[])
{        
    @autoreleasepool
    {
        MyPeripheralManagerDelegate *peripheralManagerDelegate = [[MyPeripheralManagerDelegate alloc] init];
        dispatch_queue_t ble_service = dispatch_queue_create("ble_test_service",  DISPATCH_QUEUE_SERIAL);
        CBPeripheralManager* peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:peripheralManagerDelegate queue:ble_service];
        peripheralManagerDelegate.peripheralManager = peripheralManager;

        printf("Sending\n");
        while (![peripheralManagerDelegate currentCentral]);

        NSString *stringToSend = (argc > 1) ? [NSString stringWithUTF8String:argv[1]] : @"";
        [peripheralManagerDelegate sendValue:stringToSend];
        printf("Sent\n");
    }
    return 0;
}
//------------------------------------------------------------------------------
