/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-SubviewGeometry.h"
#import <time.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

/*
 This recipe adds an animated butterfly on top of the same code used for Recipe 9
 */

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

- (void) animationFinished: (id) sender
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Flip", @selector(flip:));
}

- (void) flip: (id) sender
{
	// hide the button
	self.navigationItem.rightBarButtonItem = nil;
	
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	UIView *whiteBackdrop = [self.view viewWithTag:100];

	// Choose left or right flip
	if ([(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex])
		[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView:whiteBackdrop cache:YES];
	else
		[UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView:whiteBackdrop cache:YES];

	NSInteger purple = [[whiteBackdrop subviews] indexOfObject:[whiteBackdrop viewWithTag:999]];
	NSInteger maroon = [[whiteBackdrop subviews] indexOfObject:[whiteBackdrop viewWithTag:998]];
	[whiteBackdrop exchangeSubviewAtIndex:purple withSubviewAtIndex:maroon];

	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
	[UIView commitAnimations];
}

- (void) updateButterfly: (NSTimer *) timer
{
	UIView *butterfly = [self.view viewWithTag:300];
	
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5f];
	
	butterfly.center = [butterfly randomCenterInView:self.view withInset:10.0f];
	
	[UIView commitAnimations];	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Flip", @selector(flip:));

	// Set up the segmented control for picking the animation direction
	UISegmentedControl *seg = [[[UISegmentedControl alloc] initWithItems:[@"Left Right" componentsSeparatedByString:@" "]] autorelease];
	seg.selectedSegmentIndex = 0;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	self.navigationItem.titleView = seg;
	
	srandom(time(0));
	
	// Load butterfly images
	NSMutableArray *bflies = [NSMutableArray array];
	for (int i = 1; i <= 17; i++)
		[bflies addObject:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"bf_%d", i] ofType:@"png"]]];
	
	UIImageView *butterflyView = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 300.0f, 60.0f, 60.0f)];
	butterflyView.tag = 300;
	butterflyView.animationImages = bflies;
	butterflyView.animationDuration = 0.75f;
	[self.view addSubview:butterflyView];
	[butterflyView startAnimating];
	[butterflyView release];
	
	// start timer
	[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(updateButterfly:) userInfo:nil repeats:YES];

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
