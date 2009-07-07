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

// Start new array
- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
	self.points = [NSMutableArray array];
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self.points addObject:[NSValue valueWithCGPoint:pt]];
}

// Add each point to array
- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
	CGPoint pt = [[touches anyObject] locationInView:self];
	[self.points addObject:[NSValue valueWithCGPoint:pt]];
	[self setNeedsDisplay];
}

// Draw all points
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
	self.title = @"Simple Draw";
	
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
