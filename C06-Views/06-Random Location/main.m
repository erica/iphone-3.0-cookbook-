/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-SubviewGeometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSTimer *timer;
}
@end

@implementation TestBedViewController

- (void) move: (NSTimer *) aTimer
{
	[[self.view viewWithTag:999] moveToRandomLocationInSuperviewAnimated: YES];
}

- (void) start: (id) sender
{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(move:) userInfo:nil repeats:YES];
	[self move:nil];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Stop", @selector(stop:));
}

- (void) stop: (id) sender
{
	[timer invalidate];
	timer = nil;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(start:));
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(start:));
	
	UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 240.0f)];
	outerView.center = CGPointMake(160.0f, 140.0f);
	outerView.backgroundColor = [UIColor lightGrayColor];
	outerView.tag = 998;
	[self.view addSubview:outerView];
	[outerView release];
	
	UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
	innerView.backgroundColor = COOKBOOK_PURPLE_COLOR;
	innerView.tag = 999;
	[outerView addSubview:innerView];
	[innerView release];
	
	timer = nil;
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
