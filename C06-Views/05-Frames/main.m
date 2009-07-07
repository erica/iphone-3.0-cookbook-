/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-ViewFrameGeometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

-(void) segmentAction: (UISegmentedControl *) sc
{
	UIView *innerView = [self.view viewWithTag:999];
	UIView *outerView = [self.view viewWithTag:998];
	
	switch ([sc selectedSegmentIndex])
	{
		case 0:
			innerView.top = 0;
			break;
		case 1:
			innerView.bottom = outerView.height;
			break;
		case 2:
			innerView.left = 0;
			break;
		case 3:
			innerView.right = outerView.width;
			break;
		default:
			break;
	}
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	NSArray *buttonNames = [@"Top Bottom Left Right" componentsSeparatedByString:@" "];
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar; 
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.selectedSegmentIndex = 1;
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
	UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 240.0f)];
	outerView.center = CGPointMake(160.0f, 140.0f);
	outerView.backgroundColor = [UIColor lightGrayColor];
	outerView.tag = 998;
	[self.view addSubview:outerView];
	[outerView release];
	
	UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 80.0f, 80.0f)];
	innerView.right = outerView.width;
	innerView.bottom = outerView.height;
	innerView.backgroundColor = COOKBOOK_PURPLE_COLOR;
	innerView.tag = 999;
	[outerView addSubview:innerView];
	[innerView release];
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
