#import "StartupLaunch.h"
#import <ServiceManagement/ServiceManagement.h>
#import "Constants.h"


@implementation StartupLaunch

+ (BOOL)shouldLaunchOnStartup:(BOOL)enabled
{
    // Full path to the 'Helper App' within the Backdrop bundle
    NSURL *url = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:BACKDROP_HELPER_XPC_PATH];

    // Registering the 'Helper App'
    if (LSRegisterURL((__bridge CFURLRef)url, true) != noErr) {
        NSLog(@"LSRegisterURL failed");
        return NO;
    }

    // Setting LoginItem to enabled or disabled depending on the boolean passed through.
    if (!SMLoginItemSetEnabled((CFStringRef)BACKDROP_HELPER_IDENTIFIER, enabled)) {
        NSLog(@"SMLoginItemSetEnabled failed");
        return NO;
    }

    return YES;
}

@end
