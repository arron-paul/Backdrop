#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ApplicationsFolder : NSObject

+ (BOOL)isInApplicationsFolder;
+ (void)peformMoveToApplicationsFolderIfNecessary;

@end

NS_ASSUME_NONNULL_END
