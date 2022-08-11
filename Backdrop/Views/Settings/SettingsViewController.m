#import "SettingsViewController.h"
#import "ApplicationsFolder.h"
#import "LetsMove/PFMoveApplication.h"
#import "StartupLaunch.h"
#import "AppDelegate.h"
#import "MessageBox.h"
#import "Constants.h"
#import <Sparkle/Sparkle.h>


@interface SettingsViewController ()

@end


@implementation SettingsViewController
{
    AppDelegate *_delegate;
}

@synthesize launchOnStartup, checkForUpdates, photographer, language, activation;

- (void)viewDidLoad
{
    _delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    [super viewDidLoad];

    // Setup controls
    if ([ApplicationsFolder isInApplicationsFolder]) {
        [launchOnStartup setEnabled:YES];
        [launchOnStartup setState:[[NSUserDefaults standardUserDefaults] boolForKey:KEY_LAUNCH_ON_STARTUP]];
        [launchOnStartup setToolTip:TOOLTIP_LAUNCH_ON_STARTUP_ENABLED];
    } else {
        [launchOnStartup setState:0];
        [launchOnStartup setEnabled:NO];
        [launchOnStartup setToolTip:TOOLTIP_LAUNCH_ON_STARTUP_DISABLED];
    }

    [checkForUpdates setToolTip:TOOLTIP_CHECK_FOR_UPDATES];
    if ([[SUUpdater sharedUpdater] automaticallyChecksForUpdates]) {
        [checkForUpdates setState:1];
        [checkForUpdates setEnabled:YES];
    } else {
        [checkForUpdates setState:0];
        [checkForUpdates setEnabled:NO];
    }

    [photographer setEnabled:YES];
    [photographer setToolTip:TOOLTIP_SHOW_PHOTOGRAPHER_DETAILS];
    [photographer setState:[[NSUserDefaults standardUserDefaults] boolForKey:KEY_SHOW_PHOTOGRAPHER_DETAILS]];

    [language setEnabled:YES];
    [language setToolTip:TOOLTIP_LANGUAGE_SELECT];

    [activation setEnabled:YES];
    [activation setToolTip:TOOLTIP_ACTIVTION_SELECT];
    NSInteger clickCount = [[NSUserDefaults standardUserDefaults] integerForKey:KEY_CLICK_COUNT];
    clickCount = clickCount - 3;
    [activation selectItemAtIndex:clickCount];
}

#pragma mark - Events

- (IBAction)launchOnStartupAction:(NSButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:KEY_LAUNCH_ON_STARTUP];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (![StartupLaunch shouldLaunchOnStartup:[sender state]]) {
        [MessageBox runErrorModal:ALERT_AUTOLAUNCH_ERROR_TEXT withTitle:ALERT_AUTOLAUNCH_ERROR_TITLE];
    }
}

- (IBAction)checkForUpdatesAction:(NSButton *)sender
{
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:[sender state]];
}

- (IBAction)languageAction:(NSPopUpButton *)sender
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)activationAction:(NSPopUpButton *)sender
{
    NSInteger selectionIndex = [sender indexOfSelectedItem];
    selectionIndex = selectionIndex + 3;
    [[NSUserDefaults standardUserDefaults] setInteger:selectionIndex forKey:KEY_CLICK_COUNT];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)applyAction:(NSButton *)sender
{
    [_delegate.preferences goPreviousTab:nil];
}

- (IBAction)photographerAction:(NSButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender state] forKey:KEY_SHOW_PHOTOGRAPHER_DETAILS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - MASPreferencesWindowController

- (NSString *)viewIdentifier
{
    return @"SettingsPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(MASPREFS_PANEL_SETTINGS, nil);
}

@end
