/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

#define MAXOBJECTS	12
#define SIDELENGTH 64
#define INSET_AMT	4
#define RANDLEVEL	((random() % 128) / 256.0f)

@interface DragView : UIImageView
{
	CGPoint startLocation;
}
@end

@implementation DragView
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
		self.userInteractionEnabled = YES;
	return self;
}

// Does the point hit the view?
// Detect whether the touch "hits" the view
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event 
{
	CGPoint pt;
	float HALFSIDE = SIDELENGTH / 2.0f;
	
	// normalize with centered origin
	pt.x = (point.x - HALFSIDE) / HALFSIDE;
	pt.y = (point.y - HALFSIDE) / HALFSIDE;
	
	// x^2 + y^2 = radius
	float xsquared = pt.x * pt.x;
	float ysquared = pt.y * pt.y;
	
	// If the radius < 1, the point is within the clipped circle
	if ((xsquared + ysquared) < 1.0) return YES;
	return NO;
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate and store offset, and pop view into front if needed
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
	[[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate offset
	CGPoint pt = [[touches anyObject] locationInView:self];
	float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
	CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);

	// Bound movement into parent bounds
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);

	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);

	// Set new location
	self.center = newcenter;
}
@end


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
CGPoint randomPoint() 
{
	int half = 32; // half of flower size
	int freesize = 240 - 2 * half; // inner area
	return CGPointMake(random() % freesize + half, random() % freesize + half);
}

- (UIImage *) createImage
{
	UIColor *color = [UIColor colorWithRed:RANDLEVEL green:RANDLEVEL blue:RANDLEVEL alpha:1.0f];

	UIGraphicsBeginImageContext(CGSizeMake(SIDELENGTH, SIDELENGTH));
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Create a filled ellipse
	[color setFill];
	CGRect rect = CGRectMake(0.0f, 0.0f, SIDELENGTH, SIDELENGTH);
	CGContextAddEllipseInRect(context, rect);
	CGContextFillPath(context);
	
	// Outline the circle a couple of times
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextAddEllipseInRect(context, CGRectInset(rect, INSET_AMT, INSET_AMT));
	CGContextStrokePath(context);
	CGContextAddEllipseInRect(context, CGRectInset(rect, 2*INSET_AMT, 2*INSET_AMT));
	CGContextStrokePath(context);
	
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	srandom(time(0));
	
	// Add backdrop which will bound the movement for the flowers
	UIView *backdrop = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 282.0f)];
	backdrop.backgroundColor = [UIColor blackColor];
	backdrop.center = CGPointMake(160.0f, 140.0f);
	
	// Add the flowers to random points on the screen	
	for (int i = 0; i < MAXOBJECTS; i++)
	{
		DragView *dragger = [[DragView alloc] initWithImage:[self createImage]];
		dragger.center = randomPoint();
		dragger.userInteractionEnabled = YES;

		// Uncomment to see the actual view bounds
		// dragger.backgroundColor = [UIColor lightGrayColor];
		
		[backdrop addSubview:dragger];
		[dragger release];
	}

	[self.view  addSubview:backdrop];
	[backdrop release];
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
