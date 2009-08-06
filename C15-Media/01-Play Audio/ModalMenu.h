/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ModalMenu : NSObject
+(NSUInteger) menuWithTitle: (NSString *) title view: (UIView *) aView  andButtons:(NSArray *) buttons;
+(void) presentText: (NSString *) text inView: (UIView *) aView;
@end
