#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  // Launch Backdrop with 'BackgroundLaunch' argument
  NSError *error = nil;
  NSURL *applicationUrl = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"Backdrop"];
  [[NSWorkspace sharedWorkspace] launchApplicationAtURL:applicationUrl options:0 configuration:[NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:@"BackgroundLaunch", nil] forKey:NSWorkspaceLaunchConfigurationArguments] error:&error];

}

@end
