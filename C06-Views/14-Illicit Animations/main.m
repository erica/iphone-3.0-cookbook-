/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	int direction;
}
@end

@implementation TestBedViewController

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
}

- (void) animate: (id) sender
{
	// Set up the animation
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 1.0f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	
	switch ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]) 
	{
		case 0:
			animation.type = @"rippleEffect";
			break;
		case 1:
			animation.type = @"pageCurl";
			break;
		case 2:
			animation.type = @"pageUnCurl";
			break;
		case 3:
			animation.type = @"suckEffect";
			break;
		default:
			break;
	}

	switch (direction)
	{
		case 0:
			animation.subtype = kCATransitionFromRight;
			break;
		case 1:
			animation.subtype = kCATransitionFromTop;
			break;
		case 2:
			animation.subtype = kCATransitionFromLeft;
			break;
		case 3:
			animation.subtype = kCATransitionFromBottom;
			break;
		default:
			break;
	}

	// Perform the animation
	UIView *whitebg = [self.view viewWithTag:10];
	NSInteger purple = [[whitebg subviews] indexOfObject:[whitebg viewWithTag:99]];
	NSInteger white = [[whitebg subviews] indexOfObject:[whitebg viewWithTag:100]];
	[whitebg exchangeSubviewAtIndex:purple withSubviewAtIndex:white];
	[[whitebg layer] addAnimation:animation forKey:@"animation"];
	
	if (++direction > 3) direction -= 4;
}

- (void) viewDidLoad
{
	direction = 0;
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(animate:));
	UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[@"Ripple Curl Uncurl Suck" componentsSeparatedByString:@" "]];
	sc.segmentedControlStyle = UISegmentedControlStyleBar;
	sc. selectedSegmentIndex = 0;
	self.navigationItem.titleView = [sc autorelease];
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
