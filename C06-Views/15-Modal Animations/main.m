/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-ModalAnimationHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	int direction;
}
@end

@implementation TestBedViewController

- (void) animate: (id) sender
{
	// Hide the bar button and show the view
	self.navigationItem.rightBarButtonItem = nil;
	[self.view viewWithTag:101].alpha = 1.0f;
	
	// Bounce to 115% of the normal size
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.4f];
	[self.view viewWithTag:101].transform = CGAffineTransformMakeScale(1.15f, 1.15f);
	[UIView commitModalAnimations];

	// Return back to 100%
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3f];
	[self.view viewWithTag:101].transform = CGAffineTransformMakeScale(1.0f, 1.0f);
	[UIView commitModalAnimations];
	
	// Pause for a second and appreciate the presentation
	[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
	
	// Slowly zoom back down and hide the view
	[UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0f];
	[self.view viewWithTag:101].transform = CGAffineTransformMakeScale(0.01f, 0.01f);
	[UIView commitModalAnimations];
	
	// Restore the bar button
	[self.view viewWithTag:101].alpha = 0.0f;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Bounce", @selector(animate:));
}

- (void) viewDidLoad
{
	direction = 0;
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Bounce", @selector(animate:));
	[self.view viewWithTag:101].transform = CGAffineTransformMakeScale(0.01f, 0.01f);
	[self.view viewWithTag:101].alpha = 0.0f;
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
