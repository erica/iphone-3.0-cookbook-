/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "WebHelper.h"
#import "UIDevice-Reachability.h"

/*
 NOTE
 
 This sample code uses the WebHelper class in its default state. To add meaning, create a category that implements 
 the handleWebRequest: call. To see this in action, add the WebHelper-FileService category from the sample code
 folder, add it to the project and compile. 
 */

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <WebHelperDelegate>
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@end

@implementation TestBedViewController
@synthesize log;
- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	textView.text = self.log;
}

- (void) serviceCouldNotBeEstablished
{
	[self doLog:@"Service could not be established. Sorry."];
}

- (void) disconnect: (id) sender
{
	[WebHelper sharedInstance].isServing = NO;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start serving", @selector(serve:));
	self.log = [NSMutableString string];
	[self doLog:@"Press the button to start serving"];
}

- (void) serviceWasEstablished
{
	[self doLog:@"Service was established!"];
	[self doLog:@"Connect to\n    http://%@:%d", [UIDevice hostname], [WebHelper sharedInstance].chosenPort];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect:));
}

- (void) serviceWasLost
{
	[self disconnect:nil];
}

- (void) serve: (UIBarButtonItem *) bbi
{
	self.log = [NSMutableString string];
	self.navigationItem.rightBarButtonItem = nil;
	
	[WebHelper sharedInstance].delegate = self;
	[WebHelper sharedInstance].cwd = [NSHomeDirectory() stringByAppendingString:@"/"];
	[[WebHelper sharedInstance] startService];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start serving", @selector(serve:));
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
