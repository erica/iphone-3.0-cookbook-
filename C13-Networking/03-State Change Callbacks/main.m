/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIDevice-Reachability.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <ReachabilityWatcher>
@end

@implementation TestBedViewController

- (IBAction) enableAPMode
{
	[UIDevice setAPMode:YES];
}

- (IBAction) disableAPMode
{
	[UIDevice setAPMode:NO];
}

#pragma mark Reachability Monitoring
- (void) showAlert: (id) formatstring,...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

- (void) reachabilityChanged
{
	[self showAlert:@"Reachability has changed."];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[UIDevice scheduleReachabilityWatcher:self];
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
