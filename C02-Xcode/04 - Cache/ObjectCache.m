#import "ObjectCache.h"

@implementation ObjectCache
@synthesize myCache;
- (id) init
{
	if (!(self = [super init])) return self;
	self.myCache = [NSMutableDictionary dictionary];
	return self;
}

// These return id. You'll want to re-implement to return a real typed object
- (id) loadObjectNamed: (NSString *) someKey
{
	// Subclass this and add a real object load in here
	return @"";
}

// When an object is not found, it's loaded
- (id) retrieveObjectNamed: (NSString *) someKey
{
	id object = [self.myCache objectForKey:someKey];
	if (!object) 
	{
		object = [self loadObjectNamed:someKey];
		[self.myCache setObject:object forKey:someKey];
	}
	return object;
}

// Clear the cache at a memory warning
- (void) respondToMemoryWarning
{
	[self.myCache removeAllObjects];
}

- (void) dealloc
{
	[self.myCache removeAllObjects];
	self.myCache = nil;
	[super dealloc];
}
@end
