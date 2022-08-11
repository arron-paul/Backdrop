#import "AppDelegate.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "PreferencesWindowController.h"
#import "ApplicationsFolder.h"
#import "StartupLaunch.h"
#import "RestKit/RestKit.h"
#import "Constants.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize desktop, preferences, settings, about;

- (void)resetAndShowPreferences {
  [preferences selectControllerAtIndex: 0];
  [preferences.window makeKeyAndOrderFront:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
  // Arguments that get passed through
  bool hideWindow = NO;
  NSArray *arguments = [[NSProcessInfo processInfo] arguments];
  for (NSString *argument in arguments) {
    if ([argument isEqualToString:ARGUMENT_BACKGROUND_LAUNCH]) {
      hideWindow = YES;
      break;
    }
  }
    
  // Initial state
  [self setHasLaunchedMoreThanOnce: NO];
    
  // Super fast tooltip
  [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt: 100] forKey:@"NSInitialToolTipDelay"];
    
  // Check to see if the bundle is in the users 'Applications' folder.
  [ApplicationsFolder peformMoveToApplicationsFolderIfNecessary];
    
  // Ensure that preferences key/value pairs are populated if not already defined.
  if (![[NSUserDefaults standardUserDefaults] integerForKey:KEY_CLICK_COUNT]) {
    [[NSUserDefaults standardUserDefaults] setInteger:DEFAULT_CLICK_COUNT forKey:KEY_CLICK_COUNT];
  }
  if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_LAUNCH_ON_STARTUP]) {
    [[NSUserDefaults standardUserDefaults] setBool:DEFAULT_LAUNCH_ON_STARTUP forKey:KEY_LAUNCH_ON_STARTUP];
    [StartupLaunch shouldLaunchOnStartup: DEFAULT_LAUNCH_ON_STARTUP];
  }
  if (![[NSUserDefaults standardUserDefaults] integerForKey:KEY_SHOW_PHOTOGRAPHER_DETAILS]) {
    [[NSUserDefaults standardUserDefaults] setInteger:DEFAULT_SHOW_PHOTOGRAPHER_DETAILS forKey:KEY_SHOW_PHOTOGRAPHER_DETAILS];
  }
    
  // Initiate the MASPreferences window.
  if (preferences == nil) {
    settings = [[SettingsViewController alloc] initWithNibName:MASPREFS_PANEL_SETTINGS bundle:nil];
    about = [[AboutViewController alloc] initWithNibName:MASPREFS_PANEL_ABOUT bundle:nil];
    NSArray *controllers = [[NSArray alloc] initWithObjects: about, settings, nil];
    preferences = [[PreferencesWindowController alloc] initWithViewControllers:controllers title:APP_TITLE];
  }

  // Initiate the desktop
  if (desktop == nil) {
    desktop = [[DesktopWindowController alloc] initWithWindowNibName:MASPREFS_PANEL_DESKTOP];
  }
    
  // Hook up the triple-clicking of the desktop
  [self enableGlobalMouseEventMonitor];
    
  // Has this application been launched before?
  if (![[NSUserDefaults standardUserDefaults] boolForKey:KEY_HAS_BEEN_LAUNCHED_BEFORE]) {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_HAS_BEEN_LAUNCHED_BEFORE];
    [self resetAndShowPreferences];
  }
    
  if (!hideWindow)
    [self resetAndShowPreferences];
    
}

- (void)enableGlobalMouseEventMonitor {
    
  // Do the desktop clicking by registering it as a global system event.
  __block __weak NSEvent *mouseEvent = [NSEvent addGlobalMonitorForEventsMatchingMask:NSEventMaskLeftMouseUp handler:^(NSEvent *event) {

    // How many taps required to trigger the change of wallpaper.
    if ([event clickCount] < [[NSUserDefaults standardUserDefaults] integerForKey:KEY_CLICK_COUNT])
      return;
        
    // Is the program currently closing?
    if ([self.about isBackdropClosing])
      return;

    CGWindowID currentWindow = (CGWindowID)[event windowNumber];
    CFArrayRef foundationInfo = CFArrayCreate(NULL, (void *)&currentWindow, 1, NULL);
    CFArrayRef description = CGWindowListCreateDescriptionFromArray(foundationInfo);
    NSArray *windowInfo = (__bridge NSArray *)description;
    NSDictionary *topWindow = [windowInfo objectAtIndex:0];
        
    BOOL cancelEvent = NO;
    if ([windowInfo count] <= 0)
      cancelEvent = YES;

    CFRelease(description);
    CFRelease(foundationInfo);

    // Cannot combine this with the previous if statement as we need to CFRelease things.
    if (cancelEvent)
      return;

    if ([[topWindow objectForKey:(NSString *)kCGWindowOwnerName] isEqual:FINDER_APP_NAME]) {

      // There are two properties that we can use to determine if we are clicking on the desktop.
      // The kCGWindowLayer shows the z-position of the window, the desktop will always have a
      // z-position of -2147483603 whereas other windows will always have something bigger than that, as
      // windows cannot go behind the desktop. Otherwise the kCGWindowBounds shows the x, y, height
      // and width of a window — the desktop should always have a height and width equivalent to that
      // of the current screen resolution. We are using the window layer to determine the desktop in this example.
      if ([[topWindow objectForKey:(NSString *)kCGWindowLayer] isLessThanOrEqualTo:[NSNumber numberWithInt:-2147483603]]) {
          [self->preferences close];
          [self->desktop showWindow: nil];
          [self->desktop getRandomPhoto];
          //[NSEvent removeMonitor: self->mouseEvent];
          [NSEvent removeMonitor: mouseEvent];
      }

    }

  }];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

  // Ensure the preferences file is updated before we terminate.
  [[NSUserDefaults standardUserDefaults] synchronize];
  
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {

  [self resetAndShowPreferences];
  return YES;
  
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {

  [self setHasLaunchedMoreThanOnce: YES];
  [self resetAndShowPreferences];
  return YES;
  
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender {

  [self resetAndShowPreferences];
  return YES;
  
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {

  return YES;
  
}

@end
