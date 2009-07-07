/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <math.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSTimer *timer;
	int      theta;
}
@end

@implementation TestBedViewController

- (void) move: (NSTimer *) aTimer
{
	// Rotate each iteration by 1% of PI
    CGFloat angle = theta * (M_PI / 100.0f);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    
	// Theta ranges between 0% and 199% of PI, i.e. between 0 and 2*PI
	theta = (theta + 1) % 200;

    // For fun, scale by the absolute value of the cosine
    float degree = cos(angle);
    if (degree < 0.0) degree *= -1.0f;
    degree += 0.5f;
	
	// Create add scaling to the rotation transform
    CGAffineTransform scaled = CGAffineTransformScale(transform, degree, degree);
	
    // Apply the affine transform
    [[self.view viewWithTag:999] setTransform:scaled];
}

- (void) start: (id) sender
{
	timer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector:@selector(move:) userInfo:nil repeats:YES];
	[self move:nil];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Stop", @selector(stop:));
}

- (void) stop: (id) sender
{
	[timer invalidate];
	timer = nil;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(start:));
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Start", @selector(start:));
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BflyCircle.png"]];
	imgView.tag = 999;
	imgView.center = CGPointMake(160.0f, 143.0f);
	[self.view addSubview:imgView];
	[imgView release];
	
	timer = nil;
	theta = 0;
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
