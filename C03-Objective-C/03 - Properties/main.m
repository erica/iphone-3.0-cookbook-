/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "Car.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) action: (id) sender
{
	
	Car *myCar = [[Car alloc] init];
	myCar.year = 2001;
	myCar.make = @"Ford";
	myCar.model = @"Prefect";
	NSLog(myCar.carInfo);
	myCar.colors = [NSArray arrayWithObjects:@"Gray", @"Silver", @"Black", nil];
	[myCar release];
	
	/*
	 LOGGING SAMPLES. Uncomment these to see how the various log functions display data
	 */
	
	/*
	 NSArray *myArray = [NSArray arrayWithObjects:@"One", @"Two", @"Three", nil];
	 NSLog(@"%@", myArray);
	 CFShow(myArray);
	 printf("%s\n", [[myArray description] UTF8String]);
	 */
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
