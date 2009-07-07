/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ModalAlert.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#define MAIN_ALERT	101

@interface TestBedViewController : UIViewController <UIAlertViewDelegate>
@end

@implementation TestBedViewController

-(void) action: (UIBarButtonItem *) item
{
	// Solicit text response
	NSString *answer = [ModalAlert ask:@"What is your name?" withTextPrompt:@"Name"];
	
	// Show result based on answer
	if (answer)
		[ModalAlert say:@"Nice to meet you, %@.", answer];
	else
		[ModalAlert say:@"You can stay anonymous"];
	
	// Ask a Yes/No question and respond
	if ([ModalAlert ask:@"Are you feeling well%@?", answer ? [NSString stringWithFormat:@", %@", answer] : @", anonymous person"])
		[ModalAlert say:@"Glad to hear it."];
	else
		[ModalAlert say:@"Sorry to hear it."];
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
