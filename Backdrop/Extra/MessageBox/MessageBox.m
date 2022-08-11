#import "MessageBox.h"
#import "Constants.h"
#import <AppKit/NSAlert.h>


@implementation MessageBox

+ (void)runModalUsingSpecificParameters:(NSString *)content withTitle:(NSString *)title withStyle:(NSAlertStyle)style
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:style];
    [alert setMessageText:content];
    [alert setInformativeText:title];
    [alert runModal];
}

+ (void)runErrorModal:(NSString *)content withTitle:(NSString *)title
{
    [self runModalUsingSpecificParameters:content withTitle:title withStyle:NSAlertStyleCritical];
}

+ (void)runWarningModal:(NSString *)content withTitle:(NSString *)title
{
    [self runModalUsingSpecificParameters:content withTitle:title withStyle:NSAlertStyleWarning];
}

+ (void)runInfoModal:(NSString *)content withTitle:(NSString *)title
{
    [self runModalUsingSpecificParameters:content withTitle:title withStyle:NSAlertStyleInformational];
}

@end
