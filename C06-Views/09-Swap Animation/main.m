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
	// show the button
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Swap", @selector(swap:));
}

- (void) swap: (id) sender
{
	// hide the button
	self.navigationItem.rightBarButtonItem = nil;
	
	UIView *frontObject = [[self.view subviews] objectAtIndex:2];
	UIView *backObject = [[self.view subviews] objectAtIndex:1];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	
	frontObject.alpha = 0.0f;
	backObject.alpha = 1.0f;
	frontObject.transform = CGAffineTransformMakeScale(0.25f, 0.25f);
	backObject.transform = CGAffineTransformIdentity;
	[self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];

	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
	[UIView commitAnimations];
	
}

- (void) viewDidLoad
{
	UIView *backObject = [self.view viewWithTag:998];
	backObject.transform = CGAffineTransformMakeScale(0.25f, 0.25f);
	backObject.alpha = 0.0f;
	
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Swap", @selector(swap:));
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
