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

/* THIS IS A LEAKY METHOD */
- (void) leakyMethod
{
	NSArray *array = [[NSArray alloc] init];
	CFShow(array);
	// use the array here
}

/* THIS IS NOT LEAKY */
- (void) properMethod
{
	NSArray *array = [[NSArray alloc] init];
	// use the array here
	[array release];
}

/* THIS ISN'T LEAKY EITHER */
- (void) anotherProperMethod
{
	NSArray *array = [[[NSArray alloc] init] autorelease];
	CFShow(array);
	// use the array here
}

/* OR THIS */
- (void) yetAnotherProperMethod
{
	NSArray *array = [NSArray array];
	printf("Retain count is %d\n", [array retainCount]);
	// use the array here
}

/* BUT THIS ONE LEAKS. EVEN WITH AN AUTORELEASE OBJECT */
- (void)anotherLeakyMethod
{
	NSArray *array = [NSArray array];
	printf("Retain count after autorelease creation: %d\n", [array retainCount]);
	[array retain];
	printf("Retain count after retain is sent: %d\n", [array retainCount]);
}

/* THIS EXAMPLE SHOWS CREATING AND RELEASING A VIEW AFTER ASSIGNING IT TO self.view */
- (void) showViewExample
{
	CGRect aFrame = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);
	UIView *mainView = [[UIView alloc] initWithFrame:aFrame];
	self.view = mainView;
	[mainView release];
}

/* THIS EXAMPLE SHOWS CUSTOM SETTERS AND GETTERS IN USE */
- (void) showCustomSetter
{
	Car *myCar = [Car car];
	
	// You can use the synthesized setter and getter
	[myCar setSalable:YES];
	printf("The car %s for sale\n", myCar.isForSale ? "is" : "is not");
	
	// The normal getter and setter still work in dot notation
	myCar.forSale = NO;
	printf("The car %s for sale\n", myCar.forSale ? "is" : "is not");
	
	// But oddly enough, not the method versions. 
	// These produce run-time errors
	// [myCar setForSale:YES];
	// printf("The car %s for sale\n", [myCar forSale] ? "is" : "is not");

	// Finally, you cannot use the customized setter via dot notation.
	// This produces a compile-time error
	// myCar.setSalable = YES;
}

// THIS EXAMPLE SHOWS THE USE OF AUTORELEASE WHEN ASKING A METHOD TO RETURN A NEW OBJECT
- (Car *) fetchACar
{
	Car *myCar = [[Car alloc] init];
	return [myCar autorelease];
}

// HIGH RETAIN COUNT DEMONSTRATION
- (void) highRetainCount
{
	// On creation, view has a retain count of +1;
	UIView *view = [[[UIView alloc] init] autorelease];
	printf("Count: %d\n", [view retainCount]);
	
	// Adding it to an array increases that retain count to +2
	NSArray *array1 = [NSArray arrayWithObject:view];
	printf("Count: %d\n", [view retainCount]);
	array1;
	
	// Another array, retain count goes to +3
	NSArray *array2 = [NSArray arrayWithObject:view];
	printf("Count: %d\n", [view retainCount]);
	array2;
	
	// And another +4
	NSArray *array3 = [NSArray arrayWithObject:view];
	printf("Count: %d\n", [view retainCount]);
	array3;
}

// BASIC ACTIONS
- (void) basicDemonstration
{
	// myCar is autorelease. You do not release it at the end of the method
	Car *myCar = [Car car];
	
	// Autorelease object. The object is automatically retained by the retain-style property
	myCar.colors = [NSArray arrayWithObjects:@"Black", @"Silver", @"Gray", nil];
	
	// Non-autorelease object. Retain count is 1 after creation
	NSArray *array = [[NSArray alloc] initWithObjects:@"Black", @"Silver", @"Gray", nil];
	
	// Retain count rises to 2 by assigning to the retain-style property 
	myCar.colors = array;
	
	// You must now release and get that retain count back to 1
	[array release];
	
	// This performs another release. The retain count for array is now 0
	myCar.colors = nil;
}

// THIS IS THE METHOD THAT IS RUN WHEN YOU PRESS THE ONSCREEEN BUTTON. IT DEMONSTRATES RELEASE STRATEGIES
- (void) action: (id) sender
{
	[self basicDemonstration];
	[self showCustomSetter];
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
