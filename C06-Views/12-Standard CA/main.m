/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

#define ANIMATION_DURATION (4.0)

- (void) updateColor: (UISegmentedControl *) seg
{
	if (seg.selectedSegmentIndex) 
		[self.view viewWithTag:88].backgroundColor = [UIColor blackColor];
	else
		[self.view viewWithTag:88].backgroundColor = [UIColor whiteColor];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}

- (void) action: (id) sender
{
	self.navigationItem.rightBarButtonItem = nil;

	// Adapted from Lucas Newman's sample code (www.lucasnewman.com)
	UIView *theView = [self.view viewWithTag:101];
	[CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:ANIMATION_DURATION] forKey:kCATransactionAnimationDuration];
	
    // scale it down
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	shrinkAnimation.delegate = self;
    shrinkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    shrinkAnimation.toValue = [NSNumber numberWithFloat:0.0];
	[[theView layer] addAnimation:shrinkAnimation forKey:@"shrinkAnimation"];
	
	// fade it out
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
    fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [[theView layer] addAnimation:fadeAnimation forKey:@"fadeAnimation"];
	
	// make it jump a couple of times
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef positionPath = CGAutorelease(CGPathCreateMutable());
    CGPathMoveToPoint(positionPath, NULL, [theView layer].position.x, [theView layer].position.y);
    CGPathAddQuadCurveToPoint(positionPath, NULL, [theView layer].position.x, - [theView layer].position.y, [theView layer].position.x, [theView layer].position.y);
    CGPathAddQuadCurveToPoint(positionPath, NULL, [theView layer].position.x, - [theView layer].position.y * 1.5, [theView layer].position.x, [theView layer].position.y);
    CGPathAddQuadCurveToPoint(positionPath, NULL, [theView layer].position.x, - [theView layer].position.y * 1.25, [theView layer].position.x, [theView layer].position.y);
    positionAnimation.path = positionPath;
    positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [[theView layer] addAnimation:positionAnimation forKey:@"positionAnimation"];
    
	[CATransaction commit];	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
	[self.view viewWithTag:101].clipsToBounds = NO;
	
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"White Black" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(updateColor:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = seg;
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
