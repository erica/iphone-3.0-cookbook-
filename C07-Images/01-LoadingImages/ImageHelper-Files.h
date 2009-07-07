/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject
@end

@interface ImageHelper (Files)
+ (UIImage *) imageNamed: (NSString *) aName;
+ (UIImage *) imageFromURLString: (NSString *) urlstring;
+ (NSArray *) DCIMImages;
+ (UIImage *) DCIMImageNamed: (NSString *) aName;
@end
