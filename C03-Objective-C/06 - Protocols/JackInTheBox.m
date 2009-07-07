/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "JackInTheBox.h"


@implementation JackInTheBox
@synthesize client;
- (id) init
{
	if (!(self = [super init])) return self;
	srandom([[NSDate date] timeIntervalSince1970]);
	self.client = nil;
	return self;
}

- (void) turnTheCrank
{
	// You need a client to respond to the crank
	if (!self.client) return;
	
	// Randomly generate an action in response to the crank turn	
	int action = random() % 10;
	if (action < 1)
		[self.client jackDidAppear];
	else if (action < 8)
		[self.client musicDidPlay];
	else 
	{
		// optional client method
		if ([self.client  respondsToSelector:@selector(nothingDidHappen)])
			[self.client nothingDidHappen];
	}
}

+ (JackInTheBox *) jack;
{
	return [[[JackInTheBox alloc] init] autorelease];
}
@end
