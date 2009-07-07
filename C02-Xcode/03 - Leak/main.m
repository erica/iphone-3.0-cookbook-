/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

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
	
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"LEAK DEMO" message:outstring delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];
}

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

/*
 
 The NULL/nil assignments at the end of the two leak functions are not needed to create a leak. I've added them
 because they produce a faster leak response in Instruments.
 
 To see the array leak count, add printf("%d\n", [leakarray retainCount]);
 
 */

- (void) leakString
{
	char *leakystring = malloc(sizeof(char)*128);
	leakystring = NULL; 
}

- (void) leakArray
{
	NSArray *leakyarray = [[NSMutableArray alloc] init];
	leakyarray = nil; 
}

- (void) intro
{
	show(@"Run with Instruments using Leaks. Click a button to leak memory.\n");
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Leak Array", @selector(leakArray));
	self.navigationItem.leftBarButtonItem =  BARBUTTON(@"Leak String", @selector(leakString));
	[self performSelector:@selector(intro) withObject:nil afterDelay:0.5f];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Technically window and nav both leak but dealloc is never called for the application delegate
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
