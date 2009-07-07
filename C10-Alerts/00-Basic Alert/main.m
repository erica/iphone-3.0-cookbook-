/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#define MAIN_ALERT	101

@interface TestBedViewController : UIViewController <UIAlertViewDelegate>
@end

@implementation TestBedViewController

- (void) alertView:(UIAlertView *) alertView clickedButtonAtIndex: (int) index
{
	printf("User selected button %d\n", index);
	[alertView release];
}

- (void) showAlert: (NSString *) message
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Title" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"One", @"Two", @"Three", nil];
	av.tag = MAIN_ALERT;
    [av show];
}

- (void) action: (id) sender
{
	[self showAlert:@"Test Alert"];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
