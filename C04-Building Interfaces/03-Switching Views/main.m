/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "HelloWorldViewController.h"

@interface HelloWorldAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation HelloWorldAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	HelloWorldViewController *hwvc = [[HelloWorldViewController alloc] init];
	[window addSubview:hwvc.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"HelloWorldAppDelegate");
	[pool release];
	return retVal;
}
