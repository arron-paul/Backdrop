#import <XCTest/XCTest.h>
#import <RestKit/RestKit.h>
#import "UnsplashPhoto.h"
#import "Constants.h"

@interface BackdropTests : XCTestCase

@end

@implementation BackdropTests

- (void)testUnsplashRestfulRequest {

  RKObjectMapping *unsplashPhotoMapping = [RKObjectMapping mappingForClass:[UnsplashPhoto class]];
  [unsplashPhotoMapping addAttributeMappingsFromDictionary: [UnsplashPhoto expectedResponse]];
  RKResponseDescriptor *responseDiscriptor = [RKResponseDescriptor responseDescriptorWithMapping:unsplashPhotoMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:UNSPLASH_API_REQUEST_RANDOM]];
  [request setValue:UNSPLASH_API_VERSION forHTTPHeaderField:@"Accept-Version"];
  [request setValue:[NSString stringWithFormat:@"Client-ID %@", UNSPLASH_APP_ID] forHTTPHeaderField:@"Authorization"];
  [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
  RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDiscriptor]];
  [operation start];
  [operation waitUntilFinished];
  XCTAssert(!operation.error);
    
}

@end
