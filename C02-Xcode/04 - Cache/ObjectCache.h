#import <Foundation/Foundation.h>

@interface ObjectCache : NSObject
{
	NSMutableDictionary *myCache;
}
@property (nonatomic, retain) NSMutableDictionary *myCache;
- (id) retrieveObjectNamed: (NSString *) someKey;
- (void) respondToMemoryWarning;
@end
