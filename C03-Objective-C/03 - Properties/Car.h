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
	NSArray  *colors;
}
@property int year;
@property (retain) NSString *make;
@property (retain) NSString *model;
@property (retain) NSArray *colors;
@property (readonly) NSString *carInfo;
@end

