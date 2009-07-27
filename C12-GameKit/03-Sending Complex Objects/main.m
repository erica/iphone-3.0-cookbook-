/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"
#import "DrawView.h"

#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define COLOR_ARRAY [NSArray arrayWithObjects:[UIColor whiteColor], [UIColor lightGrayColor], [UIColor darkGrayColor], [UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor blueColor], [UIColor purpleColor],  nil]
#define BASE_TINT	[UIColor darkGrayColor]

#define DATAPATH [NSString stringWithFormat:@"%@/Documents/drawing.archive", NSHomeDirectory()]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController

// Return a 20x20 image with the given color
- (UIImage *) swatchWithColor:(UIColor *) color
{
	float side = 20.0f;
	UIGraphicsBeginImageContext(CGSizeMake(side, side));
	CGContextRef context = UIGraphicsGetCurrentContext();
	[color setFill];
	CGContextFillRect(context, CGRectMake(0.0f, 0.0f, side, side));
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

// Transmit a clear request to the draw view
- (void) doClear
{
	[(DrawView *)[self.view viewWithTag:101] clear];
}

// Transmit a color change request to the draw view
- (void) colorChange: (UISegmentedControl *) seg
{
	UIColor *color = [COLOR_ARRAY objectAtIndex:seg.selectedSegmentIndex];
	DrawView *dv = (DrawView *)[self.view viewWithTag:101];
	dv.currentColor = color;
}

// Save the interface to file
- (void) archiveInterface
{
	DrawView *dv = (DrawView *)[self.view viewWithTag:101];
	[NSKeyedArchiver archiveRootObject:dv toFile:DATAPATH];
}

// Restore interface from file or create a new one
- (void) unarchiveInterface
{
	DrawView *dv = [NSKeyedUnarchiver unarchiveObjectWithFile:DATAPATH];
	if (!dv) dv = [[[DrawView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f-30.0f)] autorelease];
	dv.userInteractionEnabled = YES;
	dv.currentColor = [UIColor whiteColor];
	dv.tag = 101;
	[self.view addSubview:dv];
}

// Customize the window contents
- (void) viewDidLoad
{
	self.view.backgroundColor = [UIColor blackColor];
	self.navigationController.navigationBar.tintColor = BASE_TINT;
	
	// Retrieve (or create) the drawing surface
	[self unarchiveInterface];
	
	// Set up the color picking segmented controller
	NSMutableArray *items = [NSMutableArray array];
	for (UIColor *color in COLOR_ARRAY) [items addObject:[self swatchWithColor:color]];
	UISegmentedControl *seg = [[[UISegmentedControl alloc] initWithItems:items] autorelease];
	seg.tag = 102;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.center = CGPointMake(160.0f, 416.0f - 15.0f);
	seg.tintColor = BASE_TINT;
	seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(colorChange:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:seg];
	
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Clear", @selector(doClear));	
	
	[GameKitHelper sharedInstance].dataDelegate = self.view;
	[GameKitHelper sharedInstance].sessionID = @"Drawing Together";
	[GameKitHelper assignViewController:self];
}	
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	TestBedViewController *tbvc;
}
@property (retain) TestBedViewController *tbvc;
@end

@implementation TestBedAppDelegate
@synthesize tbvc;
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.tbvc = [[[TestBedViewController alloc] init] autorelease];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.tbvc];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}

- (void) applicationWillTerminate: (UIApplication *) application
{
	[self.tbvc archiveInterface]; // update the defaults on quit
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
