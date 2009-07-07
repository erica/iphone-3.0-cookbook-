/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "Car.h"

@implementation Car
- (id) init
{
	self = [super init];
	if (!self) return nil;
	
	make = nil;
	model = nil;
	year = 1901;
	
	return self;
}

- (void) setMake:(NSString *) aMake andModel:(NSString *) aModel andYear: (int) aYear
{
	make = [NSString stringWithString:aMake];
	model = [NSString stringWithString:aModel];
	year = aYear;
}

- (void) printCarInfo
{
	if (!make) return;
	if (!model) return;
	
	printf("Car Info\n");
	printf("Make: %s\n", [make UTF8String]);
	printf("Model: %s\n", [model UTF8String]);
	printf("Year: %d\n", year);
}

- (int) year
{
	return year;
}
@end
