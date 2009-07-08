/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SEGMENT	[(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
#define NUMBERS	@"0123456789"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 "
#define NUMBERSPERIOD	@"0123456789."

@interface TestBedViewController : UIViewController <UITextFieldDelegate>
@end

@implementation TestBedViewController 
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSCharacterSet *cs;
	
	switch (SEGMENT)
	{
		case 0:
			cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHA] invertedSet];
			break;
		case 1:
			cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
			break;
		case 2:
			cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
			if ([textField.text rangeOfString:@"."].location == NSNotFound)
				cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERSPERIOD] invertedSet];
			break;
		case 3:
			cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
			break;
		default:
			break;
	}

	NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
	BOOL basicTest = [string isEqualToString:filtered];
	
	// Add any predicate testing here
	
	return basicTest;
}

- (void) segmentChanged: (UISegmentedControl *) seg
{
	[(UITextField *)[self.view viewWithTag:101] setText:@""];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Keyboard Dismissal";
	
	// Text field defined in interface builder
	[(UITextField *)[self.view viewWithTag:101] setDelegate:self];

	// Add segmented control with entry options
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"ABC 123 2.3 A2C" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = seg;
	[seg release];
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
