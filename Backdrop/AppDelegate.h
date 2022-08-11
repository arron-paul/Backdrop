#import <Cocoa/Cocoa.h>
#import "DesktopWindowController.h"
#import "PreferencesWindowController.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (strong, retain) DesktopWindowController *desktop;
@property (strong, retain) PreferencesWindowController *preferences;

@property (strong, retain) SettingsViewController *settings;
@property (strong, retain) AboutViewController *about;

@property BOOL hasLaunchedMoreThanOnce;

- (void) enableGlobalMouseEventMonitor;

@end
