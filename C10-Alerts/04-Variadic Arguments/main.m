/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <stdarg.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <UIAlertViewDelegate>
@end

@implementation TestBedViewController

- (void) say: (id)formatstring,...
{
	va_list arglist;
	va_start(arglist, formatstring);
	id statement = [[NSString alloc] initWithFormat:formatstring arguments:arglist];
	va_end(arglist);

	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:statement message:nil delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease];
    [av show];
	[statement release];
}

-(void) action: (UIBarButtonItem *) item
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"MM/dd/YY HH:mm:ss";
	NSString *timestamp = [formatter stringFromDate:[NSDate date]];
	
	[self say:@"At the chime, the time will be %@", timestamp];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation
{
	return YES;
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
