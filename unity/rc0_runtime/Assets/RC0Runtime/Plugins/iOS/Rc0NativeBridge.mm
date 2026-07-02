#import <Foundation/Foundation.h>

// Unity → Flutter events are delivered via NSNotification so TuanjieFramework
// can link standalone. rc0_unity_widget observes "Rc0UnitySendToFlutter".
extern "C" void NativeBridge_SendToFlutter(const char *json)
{
    if (json == NULL) return;
    NSString *payload = [NSString stringWithUTF8String:json];
    if (payload.length == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
            postNotificationName:@"Rc0UnitySendToFlutter"
                          object:nil
                        userInfo:@{ @"json": payload }];
    });
}
