#import "NSWindowFade.h"


@implementation NSWindow (NSWindowFade)

- (void)fadeInWithDuration:(NSTimeInterval)duration toAlpha:(float)alphaValue
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self isVisible] || [self alphaValue] < alphaValue) {
            if (![self isVisible])
                [self setAlphaValue:0.0f];
            [self orderFront:self];
            [NSAnimationContext beginGrouping];
            [NSAnimationContext currentContext].duration = duration;
            [self.animator setAlphaValue:alphaValue];
            [NSAnimationContext endGrouping];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_AJPostFadeFunctionality) object:nil];
    });
}

- (void)fadeInWithDuration:(NSTimeInterval)duration
{
    [self fadeInWithDuration:duration toAlpha:1.0f];
}

- (void)fadeIn
{
    [self fadeInWithDuration:0.1];
}

- (void)fadeOutWithDuration:(NSTimeInterval)duration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self isVisible])
            return;
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:duration];
        [self.animator setAlphaValue:0.0f];
        [NSAnimationContext endGrouping];
        [self performSelector:@selector(_AJPostFadeFunctionality) withObject:nil afterDelay:duration];
    });
}

- (void)fadeOut
{
    [self fadeOutWithDuration:0.1];
}

- (void)_AJPostFadeFunctionality
{
    [self willChangeValueForKey:@"visible"];
    [self orderOut:self];
    [self didChangeValueForKey:@"visible"];
}

@end
