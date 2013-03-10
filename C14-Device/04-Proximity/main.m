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

- (void) toggle: (id) sender
{
	BOOL isIt = [UIDevice currentDevice].proximityMonitoringEnabled;
	NSString *title = isIt ? @"Enable" : @"Disable";
	self.navigationItem.rightBarButtonItem = BARBUTTON(title, @selector(toggle:));
	[UIDevice currentDevice].proximityMonitoringEnabled = !isIt;

	self.log = [NSMutableString string];
	[self doLog:@"You have %@ the Proximity sensor.", isIt ? @"disabled" : @"enabled"];
	if (!isIt) [self doLog:@"View state changes on the debugger consoler as the screen is not readable when blanked."];
}

- (void) stateChange: (NSNotificationCenter *) notification
{
	NSLog(@"The proximity sensor %@", [UIDevice currentDevice].proximityState ? @"will now blank the screen" : @"will now restore the screen");
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Enable", @selector(toggle:));

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
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
