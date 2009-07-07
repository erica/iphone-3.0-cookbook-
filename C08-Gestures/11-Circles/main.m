/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define POINT(X)	[[self.points objectAtIndex:X] CGPointValue]

@interface TouchView : UIView
{
	NSMutableArray *points;
	CGRect circle;
}
@property (retain) NSMutableArray *points;
@end

@implementation TouchView
@synthesize points;

- (BOOL) isMultipleTouchEnabled {return NO;}

// Return dot product of two vectors normalized
float dotproduct (CGPoint v1, CGPoint v2)
{
	float dot = (v1.x * v2.x) + (v1.y * v2.y);
	float a = ABS(sqrt(v1.x * v1.x + v1.y * v1.y));
	float b = ABS(sqrt(v2.x * v2.x + v2.y * v2.y));
	dot /= (a * b);
	
	return dot;
}

// Return distance between two points
float distance (CGPoint p1, CGPoint p2)
{
	float dx = p2.x - p1.x;
	float dy = p2.y - p1.y;
	
	return sqrt(dx*dx + dy*dy);
}

// Calculate and return least bounding rectangle
- (CGRect) centeredRectangle
{
	float x = 0.0f;
	float y = 0.0f;
	for (NSValue *pt in self.points)
	{
		x += [pt CGPointValue].x;
		y += [pt CGPointValue].y;
	}
	
	// Calculate weighted center
	x /= self.points.count;
	y /= self.points.count;
	
	float minx = 9999.0f;
	float maxx = -9999.0f;
	float miny = 9999.0f;
	float maxy = -9999.0f;
	
	for (NSValue *pt in self.points)
	{
		minx = MIN(minx, [pt CGPointValue].x);
		miny = MIN(miny, [pt CGPointValue].y);
		maxx = MAX(maxx, [pt CGPointValue].x);
		maxy = MAX(maxy, [pt CGPointValue].y);
	}
	
	return CGRectMake(minx, miny, (maxx - minx), (maxy - miny));
}

// Return a point with respect to a given origin
CGPoint centerPoint(CGPoint pt, CGPoint origin)
{
	return CGPointMake(pt.x - origin.x, pt.y - origin.y);
}

// On new touch, start a new array of points
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
	self.points = [NSMutableArray array];
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self.points addObject:[NSValue valueWithCGPoint:pt]];
}

// Add each point to the array
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self.points addObject:[NSValue valueWithCGPoint:pt]];
	[self setNeedsDisplay];
}

// At the end of touches, determine whether a circle was drawn
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
	if (!self.points) return;
	if (self.points.count < 3) return;

	// Test 1: The start and end points must be between 60 pixels of each other
	CGRect tcircle;
	if (distance(POINT(0), POINT(self.points.count - 1)) < 60.0f)
		tcircle = [self centeredRectangle];

	// Test 2: Count the distance traveled in degrees. Must fall within 45 degrees of 2 PI
	CGPoint center = CGPointMake(CGRectGetMidX(tcircle), CGRectGetMidY(tcircle));
	float distance = ABS(acos(dotproduct(centerPoint(POINT(0), center), centerPoint(POINT(1), center))));
	for (int i = 1; i < (self.points.count - 1); i++)
		distance += ABS(acos(dotproduct(centerPoint(POINT(i), center), centerPoint(POINT(i+1), center))));
	if ((ABS(distance - 2 * M_PI) < (M_PI / 4.0f))) circle = tcircle;
	
	[self setNeedsDisplay];
}

// Show all points plus the current circle and its center
- (void) drawRect: (CGRect) rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	// draw circle
	[[UIColor redColor] set];
	CGContextAddEllipseInRect(context, circle);
	CGContextStrokePath(context);
	
	// draw center
	CGPoint center = CGPointMake(CGRectGetMidX(circle), CGRectGetMidY(circle));
	CGRect crect = CGRectMake(center.x - 2.0f, center.y - 2.0f, 4.0f, 4.0f);
	CGContextAddEllipseInRect(context, crect);
	CGContextFillPath(context);

	// Reset circle
	circle = CGRectZero;

	// Show the original shape
	if (self.points.count < 2) return;
	[[UIColor whiteColor] set];
	CGContextSetLineWidth(context, 3.0f);
	for (int i = 0; i < (self.points.count - 1); i++)
	{
		CGPoint pt1 = [[self.points objectAtIndex:i] CGPointValue];
		CGPoint pt2 = [[self.points objectAtIndex:(i+1)] CGPointValue];
		CGContextMoveToPoint(context, pt1.x, pt1.y);
		CGContextAddLineToPoint(context, pt2.x, pt2.y);
		CGContextStrokePath(context);
	}
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.view.userInteractionEnabled = YES;
	self.title = @"Circle Maker";

	TouchView *tv = [[TouchView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 240.0f)];
	tv.backgroundColor = [UIColor blackColor];
	tv.center = CGPointMake(160.0f, 140.0f);
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
