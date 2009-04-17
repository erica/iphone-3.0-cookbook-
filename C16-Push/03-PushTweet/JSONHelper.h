/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

NSString *jsonescape(NSString *string);

@interface JSONHelper : NSObject {
}
+ (NSString *) jsonWithDict: (NSDictionary *) aDictionary;
+ (NSString *) jsonWithArray: (NSArray *) array;
@end
