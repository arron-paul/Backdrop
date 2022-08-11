#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN


@interface AboutViewController : NSViewController

@property BOOL isBackdropClosing;

@property (strong) IBOutlet NSTextField *copyright;
@property (weak) IBOutlet NSTextField *version;

- (IBAction)settingsAction:(NSButton *)sender;
- (IBAction)stopAction:(NSButton *)sender;

@end

NS_ASSUME_NONNULL_END
