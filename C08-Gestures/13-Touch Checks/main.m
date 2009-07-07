/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define DX(p1, p2)	(p2.x - p1.x)
#define DY(p1, p2)	(p2.y - p1.y)

typedef enum {
	UITouchUnknown,
	UITouchTap,
	UITouchDoubleTap,
	UITouchDrag,
	UITouchMultitouchTap,
	UITouchMultitouchDoubleTap,
	UITouchSwipeLeft,
	UITouchSwipeRight,
	UITouchSwipeUp,
	UITouchSwipeDown,
	UITouchPinchIn,
	UITouchPinchOut,
} UIDevicePlatform;

// Return distance between two points
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

@interface TouchView : UIView
{
	BOOL multitouch;
	BOOL finished;
	CGPoint startPoint;
	NSUInteger touchtype;
	NSUInteger pointCount;
	UIViewController *vc;
}
@property (assign) UIViewController *vc;
@end

@implementation TouchView
@synthesize vc;

#define SWIPE_DRAG_MIN 16
#define DRAGLIMIT_MAX 8 
#define POINT_TOLERANCE 16
#define MIN_PINCH	8

- (BOOL) isMultipleTouchEnabled {return YES;}

- (void) touchesBegan:(NSSet *) touches withEvent: (UIEvent *) event
{
	finished = NO;
	startPoint = [[touches anyObject] locationInView:self];
	multitouch = (touches.count > 1);
	pointCount = 1;
}

- (void) touchesMoved:(NSSet *) touches withEvent: (UIEvent *) event
{
	pointCount++;
	if (finished) return;
	
	// Handle multitouch
	if (touches.count > 1)
	{
		// get touches
		UITouch *touch1 = [[touches allObjects] objectAtIndex:0];
		UITouch *touch2 = [[touches allObjects] objectAtIndex:1];
		
		// find current and previous points
		CGPoint cpoint1 = [touch1 locationInView:self];
		CGPoint ppoint1 = [touch1 previousLocationInView:self];
		CGPoint cpoint2 = [touch2 locationInView:self];
		CGPoint ppoint2 = [touch2 previousLocationInView:self];
		
		// calculate distances between the points
		CGFloat cdist = distance(cpoint1, cpoint2);
		CGFloat pdist = distance(ppoint1, ppoint2);
		
		multitouch = YES;

		// The pinch has to exceed a minimum distance
		if (ABS(cdist - pdist) < MIN_PINCH) return;
		
		if (cdist < pdist)
			touchtype = UITouchPinchIn;
		else
			touchtype = UITouchPinchOut;
		
		finished = YES;
		return;
	}
	else 
	{
		// Check single touch for swipe
		CGPoint cpoint = [[touches anyObject] locationInView:self];
		float dx = DX(cpoint, startPoint);
		float dy = DY(cpoint, startPoint);
		multitouch = NO;

		finished = YES;
		if ((dx > SWIPE_DRAG_MIN) && (ABS(dy) < DRAGLIMIT_MAX)) // hswipe left
			touchtype = UITouchSwipeLeft;
		else if ((-dx > SWIPE_DRAG_MIN) && (ABS(dy) < DRAGLIMIT_MAX)) // hswipe right
			touchtype = UITouchSwipeRight;
		else if ((dy > SWIPE_DRAG_MIN) && (ABS(dx) < DRAGLIMIT_MAX)) // vswipe up
			touchtype = UITouchSwipeUp;
		else if ((-dy > SWIPE_DRAG_MIN) && (ABS(dx) < DRAGLIMIT_MAX)) // vswipe down
			touchtype = UITouchSwipeDown;
		else
			finished = NO;
	}
}

- (void) touchesEnded:(NSSet *) touches withEvent: (UIEvent *) event
{
	// was not detected as a swipe
	if (!finished && !multitouch) 
	{
		// tap or double tap
		if (pointCount < 3) 
		{
			if ([[touches anyObject] tapCount] == 1) 
				touchtype = UITouchTap;
			else
				touchtype = UITouchDoubleTap;
		}
		else
			touchtype = UITouchDrag;
	}
	
	// did points exceeded proper swipe?
	if (finished && !multitouch) 
	{
		if (pointCount > POINT_TOLERANCE) touchtype = UITouchDrag;
	}
	
	// Is this properly a tap/double tap?
	if (multitouch || (touches.count > 1))
	{
		// tolerance is *very* high
		if (pointCount < 10)
		{
			if ([[touches anyObject] tapCount] == 1) 
				touchtype = UITouchMultitouchTap;
			else
				touchtype = UITouchMultitouchDoubleTap;
		}
	}
	
	NSString *whichItem = nil;
	if (touchtype == UITouchUnknown) whichItem = @"Unknown";
	else if (touchtype == UITouchTap) whichItem = @"Tap";
	else if (touchtype == UITouchDoubleTap) whichItem = @"Double Tap";
	else if (touchtype == UITouchDrag) whichItem = @"Drag";
	else if (touchtype == UITouchMultitouchTap)	whichItem = @"Multitouch Tap";
	else if (touchtype == UITouchMultitouchDoubleTap) whichItem = @"Multitouch Double Tap";
	else if (touchtype == UITouchSwipeLeft)	whichItem = @"Swipe Left";
	else if (touchtype == UITouchSwipeRight) whichItem = @"Swipe Right";
	else if (touchtype == UITouchSwipeUp) whichItem = @"Swipe Up";
	else if (touchtype == UITouchSwipeDown) whichItem = @"Swipe Down";
	else if (touchtype == UITouchPinchIn) whichItem = @"Pinch In";
	else if (touchtype == UITouchPinchOut) whichItem = @"Pinch Out";

	[self.vc performSelector:@selector(updateState:withPoints:) withObject:whichItem withObject:[NSNumber numberWithInt:pointCount]];

}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) updateState: (NSString *) whichItem withPoints: (NSNumber *) points
{
	self.title = [NSString stringWithFormat:@"%@ (%@)", whichItem, points];
}

- (void) show
{
	NSString *outstring = @"Tap, Double Tap, Drag, Multitouch Tap, Multitouch Double Tap, Swipe Left, Swipe Right, Swipe Up, Swipe Down, Pinch In, Pinch Out";
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Gestures" message:outstring delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"?", @selector(show));
	self.view.userInteractionEnabled = YES;
	self.title = @"Touch Distinction";
	
	TouchView *tv = [[TouchView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 280.0f)];
	tv.backgroundColor = [UIColor blackColor];
	tv.center = CGPointMake(160.0f, 140.0f);
	tv.vc = self;
	[self.view addSubview:tv];
	[tv release];
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
