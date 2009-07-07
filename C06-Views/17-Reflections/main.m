/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ImageHelper-Reflections.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define BASE_REFLECTION	0.25f

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

#define ANIMATION_DURATION (4.0)

- (void) updateColor: (UISegmentedControl *) seg
{
	if (seg.selectedSegmentIndex) 
		[self.view viewWithTag:88].backgroundColor = [UIColor blackColor];
	else
		[self.view viewWithTag:88].backgroundColor = [UIColor whiteColor];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[self.view viewWithTag:101].clipsToBounds = NO;
	
#define WHICH_REFLECTION	1
	if (WHICH_REFLECTION == 1)
		[ImageHelper addReflectionToView:[self.view viewWithTag:101]];
	else
		[ImageHelper addSimpleReflectionToView:[self.view viewWithTag:101]];
	
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"White Black" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(updateColor:) forControlEvents:UIControlEventValueChanged];
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
