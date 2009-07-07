/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 
 This example is based heavily on Apple Sample Code
 
 KNOWN BUGS: Your view may disappear if you release just one finger and freak out the math
 
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define MAXZOOM 2.0f
#define MINZOOM 0.5f

@interface UITouch (TouchSorting)
- (NSComparisonResult)compareAddress:(id)obj;
@end

@implementation UITouch (TouchSorting)
- (NSComparisonResult)compareAddress:(id) obj 
{
    if ((void *) self < (void *) obj) return NSOrderedAscending;
    else if ((void *) self == (void *) obj) return NSOrderedSame;
	else return NSOrderedDescending;
}
@end

@interface DragView : UIImageView
{
	CGPoint startLocation;
	CGSize originalSize;
	CGAffineTransform originalTransform;
    CFMutableDictionaryRef touchBeginPoints;
}
@end

@implementation DragView

// Prepare the drag view
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
	{
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
		self.exclusiveTouch = NO;
		originalSize = anImage.size;
		originalTransform = CGAffineTransformIdentity;
		touchBeginPoints = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
	}
	return self;
}

// Create an incremental transform matching the current touch set
- (CGAffineTransform)incrementalTransformWithTouches:(NSSet *)touches 
{
	// Sort the touches by their memory addresses
    NSArray *sortedTouches = [[touches allObjects] sortedArrayUsingSelector:@selector(compareAddress:)];
    NSInteger numTouches = [sortedTouches count];
    
	// If there are no touches, simply return identify transform.
	if (numTouches == 0) return CGAffineTransformIdentity;
	
	// Handle single touch as a translation
	if (numTouches == 1) {
        UITouch *touch = [sortedTouches objectAtIndex:0];
        CGPoint beginPoint = *(CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch);
        CGPoint currentPoint = [touch locationInView:self.superview];
		return CGAffineTransformMakeTranslation(currentPoint.x - beginPoint.x, currentPoint.y - beginPoint.y);
	}
	
	// If two or more touches, go with the first two (sorted by address)
	UITouch *touch1 = [sortedTouches objectAtIndex:0];
	UITouch *touch2 = [sortedTouches objectAtIndex:1];
	
    CGPoint beginPoint1 = *(CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch1);
    CGPoint currentPoint1 = [touch1 locationInView:self.superview];
    CGPoint beginPoint2 = *(CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch2);
    CGPoint currentPoint2 = [touch2 locationInView:self.superview];
	
	double layerX = self.center.x;
	double layerY = self.center.y;
	
	double x1 = beginPoint1.x - layerX;
	double y1 = beginPoint1.y - layerY;
	double x2 = beginPoint2.x - layerX;
	double y2 = beginPoint2.y - layerY;
	double x3 = currentPoint1.x - layerX;
	double y3 = currentPoint1.y - layerY;
	double x4 = currentPoint2.x - layerX;
	double y4 = currentPoint2.y - layerY;
	
	// Solve the system:
	//   [a b t1, -b a t2, 0 0 1] * [x1, y1, 1] = [x3, y3, 1]
	//   [a b t1, -b a t2, 0 0 1] * [x2, y2, 1] = [x4, y4, 1]
	
	double D = (y1-y2)*(y1-y2) + (x1-x2)*(x1-x2);
	if (D < 0.1) {
        return CGAffineTransformMakeTranslation(x3-x1, y3-y1);
    }
	
	double a = (y1-y2)*(y3-y4) + (x1-x2)*(x3-x4);
	double b = (y1-y2)*(x3-x4) - (x1-x2)*(y3-y4);
	double tx = (y1*x2 - x1*y2)*(y4-y3) - (x1*x2 + y1*y2)*(x3+x4) + x3*(y2*y2 + x2*x2) + x4*(y1*y1 + x1*x1);
	double ty = (x1*x2 + y1*y2)*(-y4-y3) + (y1*x2 - x1*y2)*(x3-x4) + y3*(y2*y2 + x2*x2) + y4*(y1*y1 + x1*x1);
	
    return CGAffineTransformMake(a/D, -b/D, b/D, a/D, tx/D, ty/D);
}

// Cache where each touch started
- (void)cacheBeginPointForTouches:(NSSet *)touches 
{
	for (UITouch *touch in touches) {
		CGPoint *point = (CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch);
		if (point == NULL) {
			point = (CGPoint *)malloc(sizeof(CGPoint));
			CFDictionarySetValue(touchBeginPoints, touch, point);
		}
		*point = [touch locationInView:self.superview];
	}
}

// Clear out touches from the cache
- (void)removeTouchesFromCache:(NSSet *)touches 
{
    for (UITouch *touch in touches) {
        CGPoint *point = (CGPoint *)CFDictionaryGetValue(touchBeginPoints, touch);
        if (point != NULL) {
            free((void *)CFDictionaryGetValue(touchBeginPoints, touch));
            CFDictionaryRemoveValue(touchBeginPoints, touch);
        }
    }
}

// Limit zoom to a max and min value
- (void) setConstrainedTransform: (CGAffineTransform) aTransform
{
	self.transform = aTransform;
	CGAffineTransform concat;
	CGSize asize = self.frame.size;
	
	if (asize.width > MAXZOOM * originalSize.width)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale((MAXZOOM * originalSize.width / asize.width), 1.0f));
		self.transform = concat;
	}
	else if (asize.width < MINZOOM * originalSize.width)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale((MINZOOM * originalSize.width / asize.width), 1.0f));
		self.transform = concat;
	}
	if (asize.height > MAXZOOM * originalSize.height)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(1.0f, (MAXZOOM * originalSize.height / asize.height)));
		self.transform = concat;
	}
	else if (asize.height < MINZOOM * originalSize.height)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeScale(1.0f, (MINZOOM * originalSize.height / asize.height)));
		self.transform = concat;
	}
	
	// Uncomment to force boundary checks
	
	/*	
	if (self.frame.origin.x < 0)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(-self.frame.origin.x, 0.0f));
		self.transform = concat;
	}
	
	if (self.frame.origin.y < 0)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(0.0f, -self.frame.origin.y));
		self.transform = concat;
	}

	float dx = (self.frame.origin.x + self.frame.size.width) - self.superview.frame.size.width;
	if (dx > 0.0f)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(-dx, 0.0f));
		self.transform = concat;
	}

	float dy = (self.frame.origin.y + self.frame.size.height) - self.superview.frame.size.height;
	if (dy > 0.0f)
	{
		concat = CGAffineTransformConcat(self.transform, CGAffineTransformMakeTranslation(0.0f, -dy));
		self.transform = concat;
	}
	*/
}

// Apply touches to create transform
- (void)updateOriginalTransformForTouches:(NSSet *)touches 
{
    if ([touches count] > 0) {
        CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:touches];
        [self setConstrainedTransform:CGAffineTransformConcat(originalTransform, incrementalTransform)];
		originalTransform = self.transform;
    }
}

// At start, store the touch begin points and set an original transform
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[[self superview] bringSubviewToFront:self];
    NSMutableSet *currentTouches = [[[event touchesForView:self] mutableCopy] autorelease];
    [currentTouches minusSet:touches];
    if ([currentTouches count] > 0) {
        [self updateOriginalTransformForTouches:currentTouches];
        [self cacheBeginPointForTouches:currentTouches];
    }
    [self cacheBeginPointForTouches:touches];
}

// During movement, update the transform to match the touches
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event 
{
    CGAffineTransform incrementalTransform = [self incrementalTransformWithTouches:[event touchesForView:self]];
	[self setConstrainedTransform:CGAffineTransformConcat(originalTransform, incrementalTransform)];
}

// Finish by removing touches, handling double-tap requests
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self updateOriginalTransformForTouches:[event touchesForView:self]];
    [self removeTouchesFromCache:touches];
	
    for (UITouch *touch in touches) {
        if (touch.tapCount >= 2) {
            [self.superview bringSubviewToFront:self];
        }
    }
	
    NSMutableSet *remainingTouches = [[[event touchesForView:self] mutableCopy] autorelease];
    [remainingTouches minusSet:touches];
    [self cacheBeginPointForTouches:remainingTouches];
}

// Redirect cancel to ended
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event 
{
    [self touchesEnded:touches withEvent:event];
}

- (void)dealloc {
	if (touchBeginPoints) CFRelease(touchBeginPoints);
	[super dealloc];
}
@end


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Drag, Rotate, Zoom";
	DragView *dragger = [[DragView alloc] initWithImage:[UIImage imageNamed:@"BFlyCircle.png"]];
	dragger.center = CGPointMake(160.0f, 140.0f);
	dragger.userInteractionEnabled = YES;
	[self.view addSubview:dragger];
	[dragger release];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
