#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSAlert (SynchronousSheet)

- (NSInteger)runModalSheetForWindow:(NSWindow *)aWindow;
- (NSInteger)runModalSheet;

@end

NS_ASSUME_NONNULL_END
