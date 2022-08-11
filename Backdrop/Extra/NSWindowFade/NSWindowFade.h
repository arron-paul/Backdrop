#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSWindow (NSWindowFade)

- (void)fadeIn;
- (void)fadeInWithDuration:(NSTimeInterval)duration;
- (void)fadeInWithDuration:(NSTimeInterval)duration toAlpha:(float)alphaValue;
- (void)fadeOut;
- (void)fadeOutWithDuration:(NSTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
