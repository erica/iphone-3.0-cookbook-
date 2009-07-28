/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIDevice-Reachability.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define ANNOUNCE(format, ...) printf("%s\n", [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String])

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) action: (UIBarButtonItem *) bbi
{
	ANNOUNCE(@"Host Name: %@", [UIDevice hostname]);
	ANNOUNCE(@"Local IP Addy: %@", [UIDevice localIPAddress]);
	ANNOUNCE(@"  Google IP Addy: %@", [UIDevice getIPAddressForHost:@"www.google.com"]);
	ANNOUNCE(@"  Amazon IP Addy: %@", [UIDevice getIPAddressForHost:@"www.amazon.com"]);
	ANNOUNCE(@"Local WiFI Addy: %@", [UIDevice localWiFiIPAddress]);
	if ([UIDevice networkAvailable])
		ANNOUNCE(@"What is My IP: %@", [UIDevice whatismyipdotcom]);
	
	ANNOUNCE(@"Network is%@ available %@%@", 
			 ([UIDevice networkAvailable] ? @"" : @"not"),
			 ([UIDevice activeWLAN] ? @"via WiFi" : @""),
			 ([UIDevice activeWWAN] ? @"via Cell" : @""));
	
	ANNOUNCE(@"WiFi %@", [UIDevice performWiFiCheck] ? @"is available" : @"isn't available");
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
