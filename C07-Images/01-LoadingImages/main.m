/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ImageHelper-Files.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X]

const int NUM_OPTIONS = 4;
int which = 0;

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) action: (id) sender
{
	switch (which)
	{
		case 0:
			// Load image from web
			self.title = @"URL-based image";
			SETIMAGE([ImageHelper imageFromURLString:@"http://image.weather.com/images/maps/current/curwx_600x405.jpg"]);
			break;
		case 1:
			// use UIImage's imageNamed: with caching
			self.title = @"imageNamed:";
			SETIMAGE([UIImage imageNamed:@"BFlyCircle.png"]);
			break;
		case 2:
			// Use the Image Helper version of imageNamed:
			self.title = @"Image Helper";
			SETIMAGE([ImageHelper imageNamed:@"icon.png"]);
			break;
		case 3:
			// Load normal background image from bundle
			self.title = @"Contents of file";
			SETIMAGE([UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cover320x416" ofType:@"png"]]);
			break;
		default:
			break;
	}
	
	NSString *next = [NSString stringWithFormat:@"Example %d", (which = (which + 1) % NUM_OPTIONS) + 1];
	self.navigationItem.rightBarButtonItem = BARBUTTON(next, @selector(action:));
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Example 1", @selector(action:));
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
