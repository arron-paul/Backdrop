#import "AboutViewController.h"
#import "AppDelegate.h"
#import "Constants.h"


@interface AboutViewController ()

@end


@implementation AboutViewController
{
    AppDelegate *_delegate;
}

@synthesize copyright, version;

- (void)viewDidLoad
{
    _delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    [super viewDidLoad];

    [self setIsBackdropClosing:NO];

    // Copyright string
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy"];
    NSString *copyrightStr =
        [NSString stringWithFormat:PANEL_ABOUT_COPYRIGHT,
                                   [dateFormat stringFromDate:[NSDate date]]];

    // Paragraph style
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];

    // Versions
    NSString *versionNum = [NSString stringWithFormat:
                                         PANEL_ABOUT_VERSION,
                                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    NSString *buildNum = [NSString stringWithFormat:
                                       PANEL_ABOUT_BUILD,
                                       [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];

    // Setup controls
    [copyright setStringValue:copyrightStr];
    [copyright setEditable:FALSE];
    [copyright setSelectable:FALSE];
    [version setToolTip:buildNum];
    [version setStringValue:versionNum];
} /* viewDidLoad */

- (IBAction)settingsAction:(NSButton *)sender
{
    [_delegate.preferences goNextTab:nil];
}

- (IBAction)stopAction:(NSButton *)sender
{
    PreferencesWindow *preferences = (PreferencesWindow *)_delegate.preferences.window;

    // Ensure that the close dialog is shown before it actually closes
    if (![self isBackdropClosing]) {
        if ([self shouldShowCloseDialog]) {
            [self setIsBackdropClosing:YES];
            [preferences invokeCloseDialog];
        } else
            [preferences close];
    } else
        [preferences close];
}

- (BOOL)shouldShowCloseDialog
{
    // When app not in Applications folder + also is not launching on startup
    if (![_delegate hasLaunchedMoreThanOnce])
        return YES;
    bool launchesOnStartup = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_LAUNCH_ON_STARTUP];
    if (launchesOnStartup)
        return NO;
    else
        return YES;
}

#pragma mark - MASPreferencesWindowController

- (NSString *)viewIdentifier
{
    return @"AboutPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameApplicationIcon];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(MASPREFS_PANEL_ABOUT, nil);
}

@end
