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
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	self.view = contentView;
	contentView.backgroundColor = [UIColor whiteColor];
    [contentView release];
	
	UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cover320x416.png"]];
	[self.view addSubview:iv];
	iv.userInteractionEnabled = YES;
	
	field1 = [[UITextField alloc] initWithFrame:CGRectMake(185.0, 31.0, 97.0, 31.0)];
	field1.borderStyle = UITextBorderStyleRoundedRect;
	field1.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	field1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	field2 = [[UITextField alloc] initWithFrame:CGRectMake(185.0, 97.0, 97.0, 31.0)];
	field2.borderStyle = UITextBorderStyleRoundedRect;
	field2.enabled = NO;
	field2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(95.0, 34.0, 82.0, 21.0)];
	label1.text = @"Fahrenheit";
	label1.textAlignment = UITextAlignmentLeft;
	label1.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000];
	label1.backgroundColor = [UIColor clearColor];
	
	UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(121.0, 102.0, 56.0, 21.0)];
	label2.text = @"Celsius";
	label2.textAlignment = UITextAlignmentLeft;
	label2.textColor = [UIColor colorWithRed:0.000 green:0.000 blue:0.000 alpha:1.000];
	label2.backgroundColor = [UIColor clearColor];
	
	[iv addSubview:field1];
	[iv addSubview:field2];
	[iv addSubview:label1];
	[iv addSubview:label2];
	
	[field1 release];
	[field2 release];
	[label1 release];
	[label2 release];
	
	[iv release];
	
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
