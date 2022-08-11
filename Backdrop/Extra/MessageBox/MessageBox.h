#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface MessageBox : NSObject

+ (void)runErrorModal:(NSString *)content withTitle:(NSString *)title;
+ (void)runWarningModal:(NSString *)content withTitle:(NSString *)title;
+ (void)runInfoModal:(NSString *)content withTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
