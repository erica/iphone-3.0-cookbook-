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
	NSString *salesman;
	BOOL forSale;
}
@property int year;
@property (retain) NSString *make;
@property (retain) NSString *model;
@property (retain) NSArray *colors;
@property (getter=isForSale, setter=setSalable:) BOOL forSale;
@property (readonly) NSString *carInfo;
+ (Car *) car;
@end

