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
	Car *myCar = [Car car];
	myCar.make = @"Ford";
	myCar.model = @"Prefect";
	myCar.year = 1942;
	
	// These two lines create warnings, which you can ignore
	printf("Sending string methods to the myCar Instance:\n");
	printf("UTF8String: %s\n", [(NSString *)myCar UTF8String]);
	printf("String Length: %d\n", [(NSString *)myCar length]);
	
	// This does not create a warning because it's not checked at compile time
	NSString *string = [myCar performSelector:@selector(stringByAppendingString:) withObject:@" Extra String"];
	printf("Appended: %s\n", [string UTF8String]);
	
	// This is a normal Car method but it still works
	printf("\nNormal Car instance methods\n");
	printf("Year: %d\n", [myCar year]);
	printf("Model: %s\n", [[myCar model] UTF8String]);
	
	// Bonus methods
	printf("\nBonus methods:\n");
	printf("myCar %s a kind of NSString\n", [myCar isKindOfClass:[NSString class]] ? "is" : "is not");
	printf("myCar %s to length\n", [myCar respondsToSelector:@selector(length)] ? "responds" : "doesn't respond");
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
