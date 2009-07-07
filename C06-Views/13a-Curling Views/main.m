/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) animationFinished: (id) sender
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Curl", @selector(curl:));
}

- (void) curl: (id) sender
{
	// hide the button
	self.navigationItem.rightBarButtonItem = nil;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	UIView *whiteBackdrop = [self.view viewWithTag:100];

	// Choose up or down curl
	if ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex])
		[UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:whiteBackdrop cache:YES];
	else
		[UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:whiteBackdrop cache:YES];

	NSInteger purple = [[whiteBackdrop subviews] indexOfObject:[whiteBackdrop viewWithTag:999]];
	NSInteger maroon = [[whiteBackdrop subviews] indexOfObject:[whiteBackdrop viewWithTag:998]];
	[whiteBackdrop exchangeSubviewAtIndex:purple withSubviewAtIndex:maroon];

	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
	[UIView commitAnimations];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Curl", @selector(curl:));

	// Set up the segmented control for picking the animation direction
	UISegmentedControl *seg = [[[UISegmentedControl alloc] initWithItems:[@"Down Up" componentsSeparatedByString:@" "]] autorelease];
	seg.selectedSegmentIndex = 0;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	self.navigationItem.titleView = seg;
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
