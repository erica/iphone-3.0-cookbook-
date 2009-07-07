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

// Easy Approach
/*
- (id)forwardingTargetForSelector:(SEL)sel 
{ 
	if ([self.carInfo respondsToSelector:sel]) return self.carInfo; 
	return nil;
}
*/

// More complicated but better documented approach

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
	// Check if car can handle the message
	NSMethodSignature* signature = [super methodSignatureForSelector:selector];
	
	// If not, can the car info string handle the message?
	if (!signature)
		signature = [self.carInfo methodSignatureForSelector:selector];
	
	return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	SEL selector = [invocation selector];
	
	if ([self.carInfo respondsToSelector:selector])
	{
		printf("[forwarding from %s to %s] ", [[[self class] description] UTF8String], [[NSString description] UTF8String]);
		[invocation invokeWithTarget:self.carInfo];
	}
}

/*
 
 LAGNIAPPE: A couple of bonus routines to round out things
 
 */

// Extend selector compliance
- (BOOL)respondsToSelector:(SEL)aSelector
{
	// Car class can handle the message
	if ( [super respondsToSelector:aSelector] )
		return YES;
	
	// CarInfo string can handle the message
	if ([self.carInfo respondsToSelector:aSelector])
		return YES;
	
	// Otherwise...
	return NO;
}

// Allow posing as class
- (BOOL)isKindOfClass:(Class)aClass
{
	// Check for Car
	if (aClass == [Car class]) return YES;
	if ([super isKindOfClass:aClass]) return YES;
	
	// Check for NSString
	if ([self.carInfo isKindOfClass:aClass]) return YES;
	
	return NO;
}

- (void) setMake:(NSString *) aMake andModel:(NSString *) aModel andYear: (int) aYear
{
	self.make = aMake;
	self.model = aModel;
	self.year = aYear;
}

- (NSString *) carInfo
{
	if (!self.make) return @"";
	if (!self.model) return @"";
	return [NSString stringWithFormat:@"Car Info-Make: %@, Model: %@, Year: %d", self.make, self.model, self.year];
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
