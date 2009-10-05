/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

#import "KeychainItemWrapper.h" // not used in this example but will be for upcoming ones


#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UITextField *textField;
}
@end

@implementation TestBedViewController

- (void) settings: (UIBarButtonItem *) bbi
{
	SettingsViewController *svc = [[[SettingsViewController alloc] init] autorelease];
	svc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:svc] autorelease];
	[self.navigationController presentModalViewController:nav animated:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Settings", @selector(settings:));
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
