/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#define BUTTON1		101
#define BUTTON2		102
#define CLEARVIEW	99

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (IBAction) flip: (UIButton *) button
{
	// Hide the view that's going away
	[self.view viewWithTag:BUTTON1].alpha = 1.0f;
	[self.view viewWithTag:BUTTON2].alpha = 1.0f;
	[button setAlpha:0.0f];

	// Decide which animation to use
	UIViewAnimationTransition trans;
	trans = (button.tag == BUTTON1) ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight;

	// Animate the flip
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationTransition:trans forView:[self.view viewWithTag:CLEARVIEW] cache:YES];
	[[self.view viewWithTag:CLEARVIEW] exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
	[UIView commitAnimations];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Toggle Button";	
	[self.view viewWithTag:CLEARVIEW].backgroundColor = [UIColor clearColor];
	[self.view viewWithTag:BUTTON2].alpha = 0.0f;
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
