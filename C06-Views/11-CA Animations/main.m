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
	BOOL isLeft;
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
			animation.type = kCATransitionFade;
			break;
		case 1:
			animation.type = kCATransitionMoveIn;
			break;
		case 2:
			animation.type = kCATransitionPush;
			break;
		case 3:
			animation.type = kCATransitionReveal;
		default:
			break;
	}
	if (isLeft)
		animation.subtype = kCATransitionFromRight;
	else
		animation.subtype = kCATransitionFromLeft;

	// Perform the animation
	UIView *whitebg = [self.view viewWithTag:10];
	NSInteger purple = [[whitebg subviews] indexOfObject:[whitebg viewWithTag:99]];
	NSInteger white = [[whitebg subviews] indexOfObject:[whitebg viewWithTag:100]];
	[whitebg exchangeSubviewAtIndex:purple withSubviewAtIndex:white];
	[[whitebg layer] addAnimation:animation forKey:@"animation"];
	
	// Allow or disallow user interaction (otherwise you can touch "through"
	// the cover view to enable/disable the switch)
	if (purple < white) 
		[self.view viewWithTag:99].userInteractionEnabled = YES;
	else 
		[self.view viewWithTag:99].userInteractionEnabled = NO;
	
	isLeft = !isLeft;
}

- (void) viewDidLoad
{
	isLeft = YES;
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Go", @selector(animate:));
	UISegmentedControl *sc = [[UISegmentedControl alloc] initWithItems:[@"Fade Over Push Reveal" componentsSeparatedByString:@" "]];
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
