/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define STDERR_OUT [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/stderr.txt"]

@interface TestBedViewController : UIViewController <GameKitHelperDataDelegate, UITextViewDelegate>
{
	IBOutlet UITextView *textView;
}
@end

@implementation TestBedViewController
- (void) listenForStderr: (NSTimer *) timer;
{
	NSString *contents = [NSString stringWithContentsOfFile:STDERR_OUT encoding:NSUTF8StringEncoding error:NULL];
	contents = [contents stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\n"];
	if ([contents isEqualToString:textView.text]) return;
	[textView setText:contents];
	textView.contentOffset = CGPointMake(0.0f, MAX(textView.contentSize.height - textView.frame.size.height, 0.0f));
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[GameKitHelper sharedInstance].sessionID = @"Peeking at GameKit";
	[GameKitHelper assignViewController:self];
	
	freopen([STDERR_OUT fileSystemRepresentation], "w", stderr);
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(listenForStderr:) userInfo:nil repeats:YES];
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
