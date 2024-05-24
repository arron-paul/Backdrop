#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  
  // Launch Backdrop with 'BackgroundLaunch' argument
  NSURL *applicationUrl = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier:@"Backdrop"];
  
  [[NSWorkspace sharedWorkspace] openApplicationAtURL:applicationUrl configuration:[NSWorkspaceOpenConfiguration configuration]
      completionHandler:^(NSRunningApplication* app, NSError* error) {
        if (error) {
          NSLog(@"Failed to run the app: %@", error.localizedDescription);
        }
        exit(0);
      }
  ];
  [NSThread sleepForTimeInterval: 10];

}

@end
