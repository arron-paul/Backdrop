#import "DesktopWindow.h"


@implementation DesktopWindow

- (BOOL)canBecomeKeyWindow
{
    // Ensure that we cannot accept mouse or keyboard events.
    return false;
}

@end
