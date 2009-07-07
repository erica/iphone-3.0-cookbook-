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
	BOOL curlUp;
}
@end

@implementation TestBedViewController

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Curl", @selector(curl:));
	curlUp = !curlUp;
}

- (void) curl: (id) sender
{
	// hide the button
	self.navigationItem.rightBarButtonItem = nil;

	// Set up the animation
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 0.3f;
	animation.timingFunction = UIViewAnimationCurveEaseInOut;
	animation.removedOnCompletion = NO;
	if (curlUp)
	{
		animation.type = @"pageCurl";
		animation.fillMode = kCAFillModeForwards;
		animation.endProgress = 0.7;
	}
	else
	{
		animation.type = @"pageUnCurl";
		animation.fillMode = kCAFillModeBackwards;
		animation.startProgress = 0.3;
	}

	// Perform the animation
	UIView *whitebg = [self.view viewWithTag:10];
	NSInteger purple = [[whitebg subviews] indexOfObject:[whitebg viewWithTag:99]];
	NSInteger white = [[whitebg subviews] indexOfObject:[whitebg viewWithTag:100]];
	[whitebg exchangeSubviewAtIndex:purple withSubviewAtIndex:white];
	[[whitebg layer] addAnimation:animation forKey:@"page curl"];
	
	// Allow or disallow user interaction (otherwise you can touch "through"
	// the cover view to enable/disable the switch)
	if (purple < white) 
		[self.view viewWithTag:99].userInteractionEnabled = YES;
	else 
		[self.view viewWithTag:99].userInteractionEnabled = NO;
		
}

- (void) viewDidLoad
{
	curlUp = YES;
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Curl", @selector(curl:));
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
