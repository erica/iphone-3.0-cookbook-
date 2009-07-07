/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define POINT(X)	[[self.points objectAtIndex:X] CGPointValue]

UIColor *current;

@interface TouchView : UIView
{
	NSMutableArray *points;
}
@property (retain) NSMutableArray *points;
@end

@implementation TouchView
@synthesize points;

- (BOOL) isMultipleTouchEnabled {return NO;}

// Start new array of points
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
	self.points = [NSMutableArray array];
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self.points addObject:[NSValue valueWithCGPoint:pt]];
}

// Add each touch to the points
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self.points addObject:[NSValue valueWithCGPoint:pt]];
	[self setNeedsDisplay];
}

// Return dot product of two vectors normalized
float dotproduct (CGPoint v1, CGPoint v2)
{
	float dot = (v1.x * v2.x) + (v1.y * v2.y);
	float a = ABS(sqrt(v1.x * v1.x + v1.y * v1.y));
	float b = ABS(sqrt(v2.x * v2.x + v2.y * v2.y));
	dot /= (a * b);
	
	return dot;
}

#define TOLERANCE	0.25f

// remove all intermediate points that are approximately colinear
- (void) touchesEnded:(NSSet *) touches withEvent:(UIEvent *) event
{
	if (!self.points) return;
	if (self.points.count < 3) return;
	
	// Create the filtered array
	NSMutableArray *newpoints = [NSMutableArray array];
	[newpoints addObject:[self.points objectAtIndex:0]];
	CGPoint p1 = POINT(0);
	
	// Add only those points that are inflections
	for (int i = 1; i < (self.points.count - 1); i++)
	{
		CGPoint p2 = POINT(i);
		CGPoint p3 = POINT(i+1);
		
		// Cast vectors around p2 origin
		CGPoint v1 = CGPointMake(p1.x - p2.x, p1.y - p2.y);
		CGPoint v2 = CGPointMake(p3.x - p2.x, p3.y - p2.y);
		float dot = dotproduct(v1, v2);

		// Colinear items need to be as close as possible to 180 degrees
		if (dot < -0.75f) continue;
		p1 = p2;
		[newpoints addObject:[self.points objectAtIndex:i]];
	}
	
	// Add final point
	if ([newpoints lastObject] != [self.points lastObject]) [newpoints addObject:[self.points lastObject]];
	
	// Report initial and final point counts
	NSLog(@"%@", [NSString stringWithFormat:@"%d points to %d points", self.points.count, newpoints.count]);
	
	// Update with the filtered points and draw
	self.points = newpoints;
	[self setNeedsDisplay];
}

// Draw all the points on-screen as a series of line segments
- (void) drawRect: (CGRect) rect
{
	if (!self.points) return;
	if (self.points.count < 2) return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();

	[current set];
	CGContextSetLineWidth(context, 4.0f);

	for (int i = 0; i < (self.points.count - 1); i++)
	{
		CGPoint pt1 = POINT(i);
		CGPoint pt2 = POINT(i+1);
		CGContextMoveToPoint(context, pt1.x, pt1.y);
		CGContextAddLineToPoint(context, pt2.x, pt2.y);
		CGContextStrokePath(context);
	}
}
@end

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) colorChange: (UISegmentedControl *) seg
{
	switch ([seg selectedSegmentIndex])
	{
		case 0: 
			current = [UIColor whiteColor];
			break;
		case 1:
			current = [UIColor redColor];
			break;
		case 2:
			current = [UIColor greenColor];
			break;
		case 3:
			current = [UIColor orangeColor];
			break;
		case 4:
			current = [UIColor yellowColor];
			break;
		default:
			current = [UIColor purpleColor];
			break;
	}
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.view.userInteractionEnabled = YES;
	self.title = @"Linear Drawing";
	
	TouchView *tv = [[TouchView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 240.0f)];
	tv.backgroundColor = [UIColor blackColor];
	tv.center = CGPointMake(160.0f, 140.0f);
	[self.view addSubview:tv];
	[tv release];
	
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"White Red Green Orange Yellow" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
	current = [UIColor whiteColor];
	[seg addTarget:self action:@selector(colorChange:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = seg;
	[seg release];
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
