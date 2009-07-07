/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define POINT(X)	[[self.points objectAtIndex:X] locationInView:self]

@interface TouchView : UIView
{
	NSArray *points;
}
@property (retain) NSArray *points;
@end

@implementation TouchView
@synthesize points;

- (BOOL) isMultipleTouchEnabled {return YES;}

- (void) touchesBegan:(NSSet *) touches withEvent: (UIEvent *) event
{
	self.points = [touches allObjects];
	[self setNeedsDisplay];
}

- (void) touchesMoved:(NSSet *) touches withEvent: (UIEvent *) event
{
	self.points = [touches allObjects];
	[self setNeedsDisplay];
}

- (void) drawRect: (CGRect) rect
{
	if (!self.points) return;
	if (self.points.count < 2) return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 4.0f);
	[[UIColor redColor] set];

	CGPoint pt1;
	
	// Draw circles at each point
	for (int i = 0; i < self.points.count; i++)
	{
		pt1 = POINT(i);
		CGRect rect = CGRectMake(pt1.x - 20.0f, pt1.y - 20.0f, 40.0f, 40.0f);
		CGContextFillEllipseInRect(context, rect);
	}
	
	// Draw lines between each point
	CGContextMoveToPoint(context, pt1.x, pt1.y);
	
	pt1 = POINT(0);
	
	for (int i = 1; i < self.points.count; i++)
	{
		pt1 = POINT(i % self.points.count);
		CGPoint pt2 = POINT((i + 1) % self.points.count);
		CGContextAddLineToPoint(context, pt2.x, pt2.y);
	}

	CGContextStrokePath(context);
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.view.userInteractionEnabled = YES;
	self.title = @"Multitouch";
	
	TouchView *tv = [[TouchView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 280.0f)];
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
