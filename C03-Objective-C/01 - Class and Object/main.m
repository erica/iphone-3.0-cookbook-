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
	
	// CREATING OBJECTS
	NSObject *object = [[NSObject alloc] init];
	Car *myCar = [[Car alloc] init];
	
	// CHECKING OBJECT MEMORY
	// This returns 4, the size of an object pointer
	printf("object pointer: %d\n", (int) sizeof(object));
	// This returns 4, the size of an NSObject object
	printf("object itself: %d\n", (int) sizeof(*object));
	
	// This returns 4, again the size of an object pointer
	printf("myCar pointer: %d\n", (int) sizeof(myCar));
	// This returns 16, the size of a Car object
	printf("myCar object: %d\n", (int) sizeof(*myCar));
	
	// SET UP THE OBJECT DATA
	[myCar setMake:@"Ford" andModel:@"Prefect" andYear:1986];
	
	// PRINT THE OBJECT DATA
	[myCar printCarInfo];
	
	// Alternatively, use a method that returns a value
	printf("The year of the car is %d\n", [myCar year]);

	// RELEASE THE OBJECTS AFTER OBSERVING THEM
	[myCar release];
	[object release];
	
	// RELEASE DEMONSTRATION
	myCar = [[Car alloc] init];
	
	// The retain count is 1 after creation
	printf("The retain count is %d\n", [myCar retainCount]);
	
	// This reduces the retain count to 0
	[myCar release];
	
	// Uncomment this to bomb by sending a message to a released object
	// printf("The retain count is now %d\n", [myCar retainCount]);
	
	// SELECTOR DEMONSTRATION
	// This causes the program to bomb by sending a message to an object that
	// does not implement that selector.

	// Uncomment this to bomb by sending a message to an object
	// that does not implement that selector
	// NSArray *array = [NSArray array];
	// [array printCarInfo];
	
	// STRING DEMONSTRATION
	NSString *string = @"Hello World";
	
	// This is 12 bytes of addressable memory
	printf("CString: %d\n", (int) sizeof("Hello World"));
	
	// This 4-byte object points to non-addressable memory
	printf("String object: %d\n", (int) sizeof(*string));
	printf("String constant: %d\n", (int) sizeof(@"abcdefghijkl"));
	
	// DYNAMIC TYPING DEMONSTRATION
	NSArray *array = [NSArray array];
	// This assignment is valid
	id untypedVariable = array;
	// This does nothing but lets the variable be used, avoiding a compiler warning
	untypedVariable;

	// This creates a mutable array object and assigns it to a regular array pointer
	NSArray *anotherArray = [NSMutableArray array];
	// This mutable-only method call is valid. It produces a warning,
	// which you can ignore. (warning: 'NSArray' may not respond to '-addObject:')
	// For demonstration purposes only. In real life, fix the static typing.
	[anotherArray addObject:@"Hello World"];

	// Reversing things
	NSArray *standardArray = [NSArray array];
	NSMutableArray *mutableArray;
	
	// This produces a warning about assignment from a distinct Objective-C type
	mutableArray = standardArray;
	// This will bomb at run-time
	// [mutableArray addObject:@"Hello World"];
	
	// FAST ENUMERATION
	NSArray *colors = [NSArray arrayWithObjects:@"Black", @"Silver", @"Gray", nil];
	for (NSString *color in colors)
		NSLog(@"Consider buying a %@ car", color);
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
