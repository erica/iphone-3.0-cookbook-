/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "InfoViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) info
{
	int segment = [(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex];
	int styles[3] = {UIModalTransitionStyleCoverVertical, UIModalTransitionStyleCrossDissolve, UIModalTransitionStyleFlipHorizontal};
	InfoViewController *ivc = [[[InfoViewController alloc] init] autorelease];
	ivc.modalTransitionStyle = styles[segment];
	[self presentModalViewController:ivc animated:YES];
}

- (void) loadView
{
	self.view = [[[NSBundle mainBundle] loadNibNamed:@"mainview" owner:self options:nil] lastObject];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Main View";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Info", @selector(info));
	UISegmentedControl *seg = [[[UISegmentedControl alloc] initWithItems:[@"Slide Fade Flip" componentsSeparatedByString:@" "]] autorelease];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
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
