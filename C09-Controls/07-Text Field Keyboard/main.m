/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <UITextFieldDelegate>
@end

@implementation TestBedViewController 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Keyboard Dismissal";
	
	// Text field defined in interface builder
	UITextField *tf = (UITextField *)[self.view viewWithTag:101];
	tf.delegate = self;
	
	// Create a text field by hand
	tf = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
	tf.center = CGPointMake(160.0f, 120.0f);
	tf.borderStyle = UITextBorderStyleRoundedRect;
	tf.autocorrectionType = UITextAutocorrectionTypeNo;
	tf.placeholder = @"Name";
	tf.returnKeyType = UIReturnKeyDone;
	tf.clearButtonMode = UITextFieldViewModeWhileEditing;
	tf.delegate = self;
	[self.view addSubview:tf];
	[tf release];
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
