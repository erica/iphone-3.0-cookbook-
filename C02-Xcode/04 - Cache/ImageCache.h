#import <UIKit/UIKit.h>

@interface ImageCache : NSObject 
{
	NSMutableDictionary *myCache;
}
@property (nonatomic, retain) NSMutableDictionary *myCache;
+ (ImageCache *) cache;
- (UIImage *) retrieveObjectNamed: (NSString *) someKey;
- (void) respondToMemoryWarning;
@end

