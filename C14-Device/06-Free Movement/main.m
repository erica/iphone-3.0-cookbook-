/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SIGN(x)	((x < 0.0f) ? -1.0f : 1.0f)

@interface TestBedViewController : UIViewController <UIAccelerometerDelegate>
{
	UIImageView *butterfly;
	float xaccel;
	float xvelocity;
	float yaccel;
	float yvelocity;
}
@property (retain) UIImageView *butterfly;
@end

@implementation TestBedViewController 
@synthesize butterfly;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	// extract the acceleration components
	float xx = -[acceleration x];
	float yy = [acceleration y];
	
	// Has the direction changed?
	float accelDirX = SIGN(xvelocity) * -1.0f; 
	float newDirX = SIGN(xx);
	float accelDirY = SIGN(yvelocity) * -1.0f;
	float newDirY = SIGN(yy);
	
	// Accelerate. To increase viscosity lower the additive value
	if (accelDirX == newDirX) xaccel = (abs(xaccel) + 0.85f) * SIGN(xaccel);
	if (accelDirY == newDirY) yaccel = (abs(yaccel) + 0.85f) * SIGN(yaccel);
	
	// Apply acceleration changes to the current velocity
	xvelocity = -xaccel * xx;
	yvelocity = -yaccel * yy;
}

- (CGRect) offsetButterflyBy: (float) dx and: (float) dy
{
	CGRect rect = [self.butterfly frame];
	rect.origin.x += dx;
	rect.origin.y += dy;
	return rect;
}

- (void) tick
{
	// Move the butterfly according to the current velocity vector
	CGRect rect;

	if (CGRectContainsRect(self.view.bounds, rect = [self offsetButterflyBy:xvelocity and:yvelocity]));
	else if (CGRectContainsRect(self.view.bounds, rect = [self offsetButterflyBy:xvelocity and:0.0f]));
	else if (CGRectContainsRect(self.view.bounds, rect = [self offsetButterflyBy:0.0f and:yvelocity]));
	else return;
	
	[butterfly setFrame:rect];
}

- (void) initButterfly
{
	// Load the animation cells
	NSMutableArray *bflies = [NSMutableArray array];
	for (int i = 1; i <= 17; i++) 
		[bflies addObject:[UIImage imageNamed:[NSString stringWithFormat:@"bf_%d.png", i]]];
	
	// Begin the animation
	self.butterfly = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 150.0f, 76.5f)] autorelease];
	[self.butterfly setAnimationImages:bflies];
	self.butterfly.animationDuration = 0.75f;
	[self.butterfly startAnimating];
	self.butterfly.center = CGPointMake(160.0f, 100.0f);
	
	[self.view addSubview:butterfly];
	
	// Set the butterfly's initial speed and acceleration
	xaccel = 2.0f;
	yaccel = 2.0f;
	xvelocity = 0.0f;
	yvelocity = 0.0f;
	
	// Activate the accelerometer
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
	
	// Start the physics timer
    [NSTimer scheduledTimerWithTimeInterval: 0.03f target: self selector: @selector(tick) userInfo: nil repeats: YES];	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[self initButterfly];
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
