#import "UnsplashPhoto.h"


@implementation UnsplashPhoto

- (NSString *)photographerAuthor
{
    if ([[self fullName] length] != 0)
        return [self fullName];
    else
        return [self username];
}

+ (NSDictionary *)expectedResponse {
    return @{
        @"user.username": @"username",
        @"user.name": @"fullName",
        @"user.links.html": @"profileLink",
        @"links.download": @"photoUrl",
        @"id": @"photoId"
    };
}

@end
