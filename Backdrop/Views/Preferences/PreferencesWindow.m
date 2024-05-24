#import "PreferencesWindow.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "NSAlert+SynchronousSheet.h"


@implementation PreferencesWindow

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    // Simulate ⌘+Q keypress event
    NSString *keyboardKeyPresses = [theEvent characters];
    if ([keyboardKeyPresses isEqualToString:@"q"])
        [self invokeCloseDialog];
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
    return YES;
}

- (void)invokeCloseDialog
{
    // Show terminate dialog
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert addButtonWithTitle:ALERT_FORCE_CLOSE_OPTION_CLOSE];
    [alert addButtonWithTitle: ALERT_FORCE_CLOSE_OPTION_BACKGROUND];
    [alert setMessageText:ALERT_FORCE_CLOSE_TITLE];
    [alert setInformativeText:ALERT_FORCE_CLOSE_TEXT];

    // Handle the response
    NSModalResponse response = [alert runModalSheetForWindow:self];
    switch (response) {
        // Fully terminate the application
        case NSAlertFirstButtonReturn:
            [NSApp terminate:self];
            break;
        // Keep application running in the background
        case NSAlertSecondButtonReturn:
            [self close];
            break;
    }
}

@end
