/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedController : UIViewController
{
	NSArray *array;
}
@end

@implementation TestBedController
- (void) accessArray
{
	CFShow([array self]);
}

- (void) loadView
{
	// Create background
	UIImageView *contentView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.image = [UIImage imageWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"HelloWorld.app/cover320x416.png"]];
	self.view = contentView;
    [contentView release];
	
	// Add action button
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Access Array", @selector(accessArray));

	// Cookbook style
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// Create and then release array
	array = [[NSArray alloc] init];
	[array release];
	
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedController alloc] init]];
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
