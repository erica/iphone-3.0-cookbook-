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
	IBOutlet UIView *overlay;
	IBOutlet UIView *messageView;
	CGRect mvframe;
}
@property (retain) UIView *overlay;
@property (retain) UIView *messageView;
@end

@implementation TestBedViewController
@synthesize overlay;
@synthesize messageView;

- (void) dismiss: (id) sender
{
	// Animate the message view away
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	mvframe.origin = CGPointMake(0.0f, -300.0f);
	self.messageView.frame = mvframe;
	[UIView commitAnimations];

	// Hide the overlay
	[self.overlay performSelector:@selector(setAlpha:) withObject:nil afterDelay:0.3f];
}

- (void) action: (id) sender
{
	self.overlay.frame = self.view.window.frame;
	mvframe.size.width = UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? 320.0f : 480.0f;
	mvframe.origin = CGPointMake(0.0f, -mvframe.size.height);
	self.messageView.frame = mvframe;

	// Show the overlay
	if (!self.overlay.superview) [self.view.window addSubview:self.overlay];
	self.overlay.alpha = 1.0f;
	
	// Animate the message view into place
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
	mvframe.origin = CGPointMake(0.0f, 20.0f);
	self.messageView.frame = mvframe;
	[UIView commitAnimations];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));

	// Initialize the overlay and message view
	self.overlay.alpha = 0.0f;
	[self.overlay addSubview:self.messageView];
	mvframe = messageView.frame;
	mvframe.origin = CGPointMake(0.0f, -300.0f);
	self.messageView.frame = mvframe;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		self.overlay.transform = CGAffineTransformMakeRotation(M_PI);
	else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		self.overlay.transform = CGAffineTransformMakeRotation(-M_PI / 2.0f);
	else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		self.overlay.transform = CGAffineTransformMakeRotation(M_PI / 2.0f);
	else 
		self.overlay.transform = CGAffineTransformIdentity;
	return YES;
}

- (void) dealloc
{
	self.overlay = nil;
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
