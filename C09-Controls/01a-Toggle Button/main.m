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
	UIImage *baseGreen;
	UIImage *altGreen;
	UIImage *baseRed;
	UIImage *altRed;
	
	BOOL isOn;
}
@end

@implementation TestBedViewController

- (void) toggleButton: (UIButton *) button
{
	if (isOn = !isOn)
	{
		[button setTitle:@"On" forState:UIControlStateNormal];
		[button setTitle:@"On" forState:UIControlStateHighlighted];
		[button setBackgroundImage:baseGreen forState:UIControlStateNormal];
		[button setBackgroundImage:altGreen forState:UIControlStateHighlighted];
	}
	else
	{
		[button setTitle:@"Off" forState:UIControlStateNormal];
		[button setTitle:@"Off" forState:UIControlStateHighlighted];
		[button setBackgroundImage:baseRed forState:UIControlStateNormal];
		[button setBackgroundImage:altRed forState:UIControlStateHighlighted];
	}
}


- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Toggle Button";
	
	float capWidth = 110.0f;
	baseGreen = [[[UIImage imageNamed:@"green.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0f] retain];
	baseRed = [[[UIImage imageNamed:@"red.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0f] retain];
	altGreen = [[[UIImage imageNamed:@"green2.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0f] retain];
	altRed = [[[UIImage imageNamed:@"red2.png"] stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0f] retain];
	
	// Create a button sized to our art
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(0.0f, 0.0f, 300.0f, 233.0f);
	button.center = CGPointMake(160.0f, 140.0f);
	
	// Set up the button aligment properties
	button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// Set the font and color
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
	
	// Add action
	[button addTarget:self action:@selector(toggleButton:) forControlEvents: UIControlEventTouchUpInside];
	
	// For tracking the two states
	isOn = NO;
	[self toggleButton:button];

	// Place the butto into the view
	[self.view addSubview:button];
	
}

- (void) dealloc
{
	[baseGreen release];
	[altGreen release];
	[baseRed release];
	[altRed release];
	[super dealloc];
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
