/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-ModalAnimationHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define NUMBER(X) [NSNumber numberWithFloat:X]

@interface TestBedViewController : UIViewController
{
	IBOutlet UIButton *dangerButton;
}
@end

@implementation TestBedViewController

// Zoom by factor
- (void) expand: (NSNumber *) aFactor
{
	dangerButton.transform = CGAffineTransformMakeScale(aFactor.intValue, aFactor.intValue);
}

// Rotate by 90 degrees
- (void) rotate
{
	dangerButton.transform = CGAffineTransformRotate(dangerButton.transform, M_PI_2);
}

// Set alpha to new level
- (void) updateAlpha: (NSNumber *) level
{
	dangerButton.alpha = level.floatValue;
}

// Flip left
- (void) flipLeft
{
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:dangerButton cache:NO];
}

// Reassert original identity transform
- (void) restore
{
	dangerButton.transform = CGAffineTransformIdentity;
}

// Move to a random location
- (void) randomMove
{
	CGRect vf = CGRectMake(0.0f, 0.0f, 320.0f, 280.0f);
	CGRect subRect = CGRectInset(vf, dangerButton.frame.size.width / 2.0f, dangerButton.frame.size.height / 2.0f);
	float rx = (float)(random() % (int)floor(subRect.size.width));
	float ry = (float)(random() % (int)floor(subRect.size.height));
	dangerButton.center = CGPointMake(rx + subRect.origin.x, ry + subRect.origin.y);
}

// React to the switch value change by animating the danger button
- (IBAction) doSwitch: (UISwitch *) aSwitch
{
	dangerButton.enabled = aSwitch.isOn;

	// Adjust button alpha level to match the enabled/disabled state
	NSNumber *aLevel = NUMBER((dangerButton.enabled) ? 1.0f : 0.25f);
	[UIView modalAnimationWithTarget:self selector:@selector(updateAlpha:) object:aLevel duration:0.3f];
	dangerButton.transform = CGAffineTransformIdentity;
	
	if (!dangerButton.enabled) return;
	
	// When the switch enables the button, add a little animation to introduce the change. Zoom out and in
	[UIView modalAnimationWithTarget:self selector:@selector(expand:) object:NUMBER(2.0f) duration:0.3f];
	[UIView modalAnimationWithTarget:self selector:@selector(expand:) object:NUMBER(1.0f) duration:0.3f];
	
	// Rotate by 360 degrees
	for (int i = 0; i < 4; i++)
		[UIView modalAnimationWithTarget:self selector:@selector(rotate) object:nil duration:0.3f];
	
	// Flip to back and again to front
	for (int i = 0; i < 2; i++)
		[UIView modalAnimationWithTarget:self selector:@selector(flipLeft) object:nil duration:1.0f];
}

// Roll the dice and possibly "boom"
- (void) boom
{
	[UIView modalAnimationWithTarget:self selector:@selector(randomMove) object:nil duration:0.1f];
	if ((random() % 12) != 4) return;
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Boom" message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

- (void) viewDidLoad
{
	srandom(time(0));
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	dangerButton.alpha = 0.25f;
	[dangerButton addTarget:self action:@selector(boom) forControlEvents:UIControlEventTouchDown];
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
