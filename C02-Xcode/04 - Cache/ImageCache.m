#import "ImageCache.h"

// MyCreateBitmapContext: Source based on Apple Sample Code
CGContextRef MyCreateBitmapContext (int pixelsWide,
									int pixelsHigh)
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );
	
    return context;
}


UIImage *buildImage(int imgsize)
{
	CGContextRef context  = MyCreateBitmapContext(imgsize, imgsize);
	CGImageRef myRef = CGBitmapContextCreateImage(context);
	free(CGBitmapContextGetData(context));
	CGContextRelease(context);
	UIImage *img = [UIImage imageWithCGImage:myRef];
	CFRelease(myRef);
	return img;
}

@implementation ImageCache
@synthesize myCache;
+ (ImageCache *) cache
{
	return [[[ImageCache alloc] init] autorelease];
}

- (id) init
{
	if (!(self = [super init])) return self;
	self.myCache = [NSMutableDictionary dictionary];
	return self;
}

- (UIImage *) loadObjectNamed: (NSString *) someKey
{
	// This doesn't actually use the key to retrieve data from the web or locally
	// It just returns another image to fill up memory
	return buildImage(320);
}

- (UIImage *) retrieveObjectNamed: (NSString *) someKey
{
	UIImage *object = [self.myCache objectForKey:someKey];
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
