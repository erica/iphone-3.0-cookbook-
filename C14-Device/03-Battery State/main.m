/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@property (retain) UITextView *textView;
@end

@implementation TestBedViewController
@synthesize log;
@synthesize textView;

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	self.textView.text = self.log;
}

- (void) checkBattery: (id) sender
{
	NSArray *stateArray = [NSArray arrayWithObjects: @"Battery state is Unknown", @"Battery is not plugged into a charging source", @"Battery is charging", @"Battery state is full", nil];
	self.log = [NSMutableString string];
	[self doLog:@"Battery level: %0.2f%", [[UIDevice currentDevice] batteryLevel] * 100];
	[self doLog:@"Battery state: %@", [stateArray objectAtIndex:[[UIDevice currentDevice] batteryState]]];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;

	// Enable battery monitoring
	[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBattery:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBattery:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];

	// Keep checking
	[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(checkBattery:) userInfo:nil repeats:YES];
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
