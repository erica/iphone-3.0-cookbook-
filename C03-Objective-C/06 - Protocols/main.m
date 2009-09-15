/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "JackInTheBox.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]


@interface TestBedViewController : UIViewController <JackClient>
{
	JackInTheBox *jack;
}
@property (retain) JackInTheBox *jack;
@end

@implementation TestBedViewController
@synthesize jack;

/*
 // Required client method
- (void) jackDidAppear
{
	NSLog(@"The Jack jumped out of the box.");
}

// Required client method
- (void) musicDidPlay
{
	NSLog(@"Music played.");
}

// Optional client method, nothingDidHappen. You can comment this out and
// still conform to the JackClient protocol
- (void) nothingDidHappen
{
	NSLog(@"Nothing happened. No music, no jack.");
} */

// Tell the jack to turn the crank
- (void) action: (id) sender
{
	[jack turnTheCrank];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
	
	self.jack = [JackInTheBox jack];
	self.jack.client = self;
}

- (void) dealloc
{
	self.jack = nil;
	[super dealloc];
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
