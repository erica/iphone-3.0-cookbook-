/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface HelloWorldController : UIViewController {
    UITextField *field1;
    UITextField *field2;
}
-(void) convert: (id)sender;
@end

@implementation HelloWorldController
- (void) convert: (id) sender
{
	float invalue = [[field1 text] floatValue];
	float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
	[field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
	[field1 resignFirstResponder];
}
- (void)loadView
{
	self.view = [[[NSBundle mainBundle] loadNibNamed:@"mainview" owner:self options:NULL] lastObject];
	field1 = (UITextField *)[self.view viewWithTag:101];
	field2 = (UITextField *)[self.view viewWithTag:102];
	self.title = @"Converter";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Convert", @selector(convert:));
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[HelloWorldController alloc] init]];
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
