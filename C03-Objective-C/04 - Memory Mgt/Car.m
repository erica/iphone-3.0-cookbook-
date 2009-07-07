/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "Car.h"

@implementation Car
@synthesize make;
@synthesize model;
@synthesize year;
@synthesize colors;
@synthesize forSale;

- (id) init
{
	self = [super init];
	if (!self) return nil;
	
	self.make = nil;
	self.model = nil;
	self.year = 1901;
	self.colors = nil;
	self.forSale = YES;
	salesman = nil;
	
	return self;
}

- (void) setMake:(NSString *) aMake andModel:(NSString *) aModel andYear: (int) aYear
{
	self.make = [NSString stringWithString:aMake];
	self.model = [NSString stringWithString:aModel];
	self.year = aYear;
}

- (NSString *) carInfo
{
	if (!self.make) return @"";
	if (!self.model) return @"";
	return [NSString stringWithFormat:@"Car Info\nMake: %@\nModel: %@\nYear: %d", self.make, self.model, self.year];
}

- (void) dealloc
{
	self.make = nil;
	self.model = nil;
	self.colors = nil;
	[salesman release];
	[super dealloc];
}

+ (Car *) car
{
	return [[[Car alloc] init] autorelease];
}
@end
