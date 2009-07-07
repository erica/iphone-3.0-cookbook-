/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface Car : NSObject
{
	int year;
	NSString *make;
	NSString *model;
}
- (void) setMake:(NSString *) aMake andModel:(NSString *) aModel andYear: (int) aYear;
- (void) printCarInfo;
- (int) year;
@end

