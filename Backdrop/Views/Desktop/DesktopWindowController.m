#import "DesktopWindowController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "Secrets.h"
#import "MessageBox.h"
#import "NSWindowFade.h"
#import "UnsplashPhoto.h"
#import <CoreImage/CoreImage.h>
#import <RestKit/RestKit.h>


@interface DesktopWindowController ()

@end


@implementation DesktopWindowController
{
    AppDelegate *_delegate;
}

@synthesize progressSpinner, photographerDetails, controls, restfulOperation;

- (void)windowDidLoad
{
    _delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [super windowDidLoad];
}

- (void)showWindow:(id)sender
{
    // Set-up and fade the backdrop into view
    [self.window setFrame:[[NSScreen mainScreen] frame] display:true];
    [self.window fadeInWithDuration:2 toAlpha:1.0f];
    [super showWindow:sender];
}

- (void)awakeFromNib
{
    // Set look-and-feel for this NSWindow
    [self.window setOpaque:NO];
    [self.window setHasShadow:NO];
    [self.window setStyleMask:NSWindowStyleMaskBorderless];
    [self.window setLevel:-1000000];
    [self.window setFrame:[[NSScreen mainScreen] frame] display:true];
    [self.window setIgnoresMouseEvents:NO];
    [self.window setAlphaValue:0.0f];
    [self.window setBackgroundColor:[NSColor colorWithWhite:0.0 alpha:0.75]];
}

- (void)getRandomPhoto
{
    // Reset the state of interface controls
    [controls setAlphaValue:0.0];
    [progressSpinner setDoubleValue:0.0f];
    [photographerDetails setStringValue:[[NSString alloc] init]];

    // Dark mode
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"AppleInterfaceStyle"] isEqual:@"Dark"])
        [controls setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];

    // Mapping between UnsplashPhoto and the expected JSON response
    RKObjectMapping *photoObject = [RKObjectMapping mappingForClass:[UnsplashPhoto class]];
    [photoObject addAttributeMappingsFromDictionary: [UnsplashPhoto expectedResponse]];

    // Initiate the request
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UNSPLASH_API_REQUEST_RANDOM]];
    [req setValue:UNSPLASH_API_VERSION forHTTPHeaderField:@"Accept-Version"];
    [req setValue:[NSString stringWithFormat:@"Client-ID %@", UNSPLASH_APP_ID] forHTTPHeaderField:@"Authorization"];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData]; // may be affected by API limits
    RKObjectRequestOperation *op = [[RKObjectRequestOperation alloc] initWithRequest:req responseDescriptors:@[
        [RKResponseDescriptor
            responseDescriptorWithMapping:photoObject
                                   method:RKRequestMethodAny
                              pathPattern:nil
                                  keyPath:nil
                              statusCodes:nil]
    ]];
    [op setCompletionBlockWithSuccess:^(RKObjectRequestOperation *op, RKMappingResult *responseObject) {
        // Iterate through all objects (there should only be one, as we're only retrieving one random photo)
        for (NSManagedObject *object in responseObject.array)
            if ([object isKindOfClass:[UnsplashPhoto class]]) {
                // Set the photo and initiate the download of the contents
                self->photo = (UnsplashPhoto *)object;
                [self downloadPhoto];
            }
    }
        failure:^(RKObjectRequestOperation *op, NSError *err) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:ALERT_SHARED_BUTTON_OK];
            long errCode = [op.HTTPRequestOperation.response statusCode];
            [alert setAlertStyle:NSAlertStyleCritical];
            switch (errCode) {
                case 401:
                    [alert setMessageText:DOWNLOAD_RESPONSE_401_TITLE];
                    [alert setInformativeText:DOWNLOAD_RESPONSE_401_BODY];
                    break;
                case 403:
                    [alert setMessageText:DOWNLOAD_RESPONSE_403_TITLE];
                    [alert setInformativeText:DOWNLOAD_RESPONSE_403_BODY];
                    break;
                case 404:
                    [alert setMessageText:DOWNLOAD_RESPONSE_404_TITLE];
                    [alert setInformativeText:DOWNLOAD_RESPONSE_404_BODY];
                default:
                    [alert setMessageText:[NSString stringWithFormat:DOWNLOAD_RESPONSE_TITLE, errCode]];
                    [alert setInformativeText:DOWNLOAD_RESPONSE_BODY];
                    break;
            }
            [alert runModal];
            [self finalizeAndFadeOut];
            // todo: return here?
        }];

    // Start and retain the RestKit operation
    [op start];
    self.restfulOperation = op;
}

- (void)downloadPhoto
{
    if (!photo) {
        [MessageBox runErrorModal:ALERT_API_DATA_ISSUE_TEXT withTitle:ALERT_API_DATA_ISSUE_TITLE];
        [self finalizeAndFadeOut];
        return;
    }

    // Fade-in the controls
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [[self->controls animator] setAlphaValue:1.0];
        }];
    });

    // Create the NSURLSession that handles the networking.
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *download = [session downloadTaskWithURL:[NSURL URLWithString:[photo photoUrl]]];
    [download resume];

    // Assign label value with the details of who took the photo
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KEY_SHOW_PHOTOGRAPHER_DETAILS])
        [photographerDetails setStringValue:[UI_LABEL_PHOTO_BY stringByAppendingString:[photo photographerAuthor]]];
    else
        [photographerDetails setStringValue:[[NSString alloc] init]];
}

- (void)finalizeAndFadeOut
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_delegate enableGlobalMouseEventMonitor];
        [self.window fadeOutWithDuration:2.0];
    });
}

#pragma mark NSURLSessionDownload delegates

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSError *error = nil;

    // NSData of the photo
    NSData *photoData = [[NSBitmapImageRep imageRepWithData:[NSData dataWithContentsOfURL:location]] representationUsingType:NSBitmapImageFileTypeJPEG properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor]];

    // Check to see if the Unsplash Wallpapers folder already exists in the users Pictures folder
    BOOL folderExists;
    NSString *directoryUnsplash = [[[[NSFileManager defaultManager] URLForDirectory:NSPicturesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error] path] stringByAppendingString:BACKDROP_FOLDER];

    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryUnsplash isDirectory:&folderExists]) {
        // Create Unsplash Wallpapers folder
        NSDictionary *attributes = [[NSDictionary alloc] init];
        [[NSFileManager defaultManager] createDirectoryAtPath:directoryUnsplash withIntermediateDirectories:YES attributes:attributes error:&error];

        // Custom folder icon
        [[NSWorkspace sharedWorkspace] setIcon:[NSImage imageNamed:@"FolderIcon"] forFile:directoryUnsplash options:0];
    }

    // Filename for the photo
    NSString *photoFilename = [[[[photo photoId] stringByAppendingString:@" by "] stringByAppendingString:[photo photographerAuthor]] stringByAppendingString:@".jpg"];
    NSString *photoAbsolutePath = [directoryUnsplash stringByAppendingString:photoFilename];

    // Write photo to file
    if (![photoData writeToFile:photoAbsolutePath atomically:YES]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MessageBox runErrorModal:[NSString stringWithFormat:ALERT_CANNOT_SAVE_PHOTO, directoryUnsplash] withTitle:[[NSString alloc] init]];
        });
        [self finalizeAndFadeOut];
        return;
    }

    // Set photo as wallpaper
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    for (NSScreen *screen in [NSScreen screens]) {
        NSDictionary *options = [workspace desktopImageOptionsForScreen:screen];
        if (![workspace setDesktopImageURL:[NSURL fileURLWithPath:photoAbsolutePath] forScreen:screen options:options error:&error]) {
            [MessageBox runErrorModal:[error localizedDescription] withTitle:@"Error changing wallpaper"];
        }
    }

    [self finalizeAndFadeOut];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    // Update the value of the progress control.
    float progress = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->progressSpinner setDoubleValue:progress * 100];
    });
}

@end
