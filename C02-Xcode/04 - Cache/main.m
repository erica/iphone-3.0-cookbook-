/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ImageCache.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

// Quick Information Display
void show(id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"CACHE DEMO" message:outstring delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];
}

@interface TestBedViewController : UIViewController
{
	ImageCache *ic;
}
@property (nonatomic, retain)	ImageCache *ic;
@end

@implementation TestBedViewController
@synthesize ic;

- (void)didReceiveMemoryWarning
{
	[self.ic respondToMemoryWarning];
}

- (void) loadImage
{
	// This causes a new image to be loaded as each time is unique. When you 
	// click twice within the same second, the retrieved object will not
	// be generated the second time because the date is the same.
	[self.ic retrieveObjectNamed:[[NSDate date] description]];
}

- (void) intro
{
	show(@"Run with Instruments using Object Allocations. Click Consume to cache a new image; more clicks mean more memory. After several clicks, choose Hardware > Simulate Memory Warnings. This clears the cache and decreases object allocations.\n");
}

- (void) viewDidLoad
{
	self.ic = [ImageCache cache];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Consume", @selector(loadImage));
	[self performSelector:@selector(intro) withObject:nil afterDelay:0.5f];
}

- (void) dealloc
{
	self.ic = nil;
	[super dealloc];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	show(@"Application Did Receive Memory Warning");
}

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
