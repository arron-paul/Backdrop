#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface UnsplashPhoto : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *profileLink;
@property (nonatomic, copy) NSString *photoUrl;
@property (nonatomic, copy) NSString *photoId;

- (NSString *)photographerAuthor;

+ (NSDictionary *)expectedResponse;

@end

NS_ASSUME_NONNULL_END
