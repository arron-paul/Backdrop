#import "UnsplashPhoto.h"
#import <Cocoa/Cocoa.h>
#import <RestKit/RestKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface DesktopWindowController : NSWindowController <NSURLSessionDelegate>
{
    UnsplashPhoto *photo;
}

@property (weak) IBOutlet NSProgressIndicator *progressSpinner;
@property (weak) IBOutlet NSTextField *photographerDetails;
@property (strong) IBOutlet NSStackView *controls;
@property (nonatomic, strong) RKObjectRequestOperation *restfulOperation;

- (void)getRandomPhoto;

@end

NS_ASSUME_NONNULL_END
