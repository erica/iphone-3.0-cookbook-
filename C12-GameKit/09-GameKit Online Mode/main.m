/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"
#import "BonjourHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <GameKitHelperDataDelegate, UITextViewDelegate>
{
	IBOutlet UITextView *sendView;
	IBOutlet UITextView *receiveView;
}
@end

@implementation TestBedViewController

- (void)textViewDidChange:(UITextView *)textView
{
	NSString *text = sendView.text;
	if (!text || (text.length == 0)) text = @"xyzzyclear";
	NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
	
	if ([GameKitHelper sharedInstance].isConnected) [GameKitHelper sendData:textData];
	if ([BonjourHelper sharedInstance].isConnected) [BonjourHelper sendData:textData];
}

-(void) receivedData: (NSData *) data
{
	NSString *text = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	receiveView.text = [text isEqualToString:@"xyzzyclear"] ? @"" : text;
}

- (void) clear
{
	sendView.text = @"";
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Clear", @selector(clear));

	[GameKitHelper sharedInstance].sessionID = @"TypingTogether"; // must have no spaces
	[GameKitHelper sharedInstance].dataDelegate = self;
	[GameKitHelper assignViewController:self];

	[sendView becomeFirstResponder];		
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
