#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

NS_ASSUME_NONNULL_BEGIN


@interface SettingsViewController : NSViewController <MASPreferencesViewController>

@property (strong) IBOutlet NSButton *launchOnStartup;
@property (strong) IBOutlet NSButton *checkForUpdates;
@property (strong) IBOutlet NSPopUpButton *language;
@property (strong) IBOutlet NSPopUpButton *activation;
@property (strong) IBOutlet NSButton *photographer;

- (IBAction)launchOnStartupAction:(NSButton *)sender;
- (IBAction)checkForUpdatesAction:(NSButton *)sender;
- (IBAction)languageAction:(NSPopUpButton *)sender;
- (IBAction)activationAction:(NSPopUpButton *)sender;
- (IBAction)applyAction:(NSButton *)sender;
- (IBAction)photographerAction:(NSButton *)sender;

@end

NS_ASSUME_NONNULL_END
