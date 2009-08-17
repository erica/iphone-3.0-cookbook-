/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface DragView : UIImageView
{
	CGPoint startLocation;
	NSString *whichFlower;
}
@property (retain) NSString *whichFlower;
@end

@implementation DragView
@synthesize whichFlower;
- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate and store offset, and pop view into front if needed
	CGPoint pt = [[touches anyObject] locationInView:self];
	startLocation = pt;
	[[self superview] bringSubviewToFront:self];
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Calculate offset
	CGPoint pt = [[touches anyObject] locationInView:self];
	float dx = pt.x - startLocation.x;
	float dy = pt.y - startLocation.y;
	CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);

	// Bound movement into parent bounds
	float halfx = CGRectGetMidX(self.bounds);
	newcenter.x = MAX(halfx, newcenter.x);
	newcenter.x = MIN(self.superview.bounds.size.width - halfx, newcenter.x);

	float halfy = CGRectGetMidY(self.bounds);
	newcenter.y = MAX(halfy, newcenter.y);
	newcenter.y = MIN(self.superview.bounds.size.height - halfy, newcenter.y);

	// Set new location
	self.center = newcenter;
}

- (void) dealloc
{
	self.whichFlower = nil;
	[super dealloc];
}
@end


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
#define MAXFLOWERS 12

- (void) updateDefaults
{
	NSMutableArray *colors =  [[NSMutableArray alloc] init];
	NSMutableArray *locs = [[NSMutableArray alloc] init];
	
	for (DragView *dv in [[self.view viewWithTag:201] subviews]) 
	{
		[colors addObject:dv.whichFlower];
		[locs addObject:NSStringFromCGRect(dv.frame)];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:colors forKey:@"colors"];
	[[NSUserDefaults standardUserDefaults] setObject:locs forKey:@"locs"];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[colors release];
	[locs release];
}


CGPoint randomPoint() 
{
	int half = 32; // half of flower size
	int freesize = 240 - 2 * half; // inner area
	return CGPointMake(random() % freesize + half, random() % freesize + half);
}

- (void) loadFlowersInView: (UIView *) backdrop
{
	// Attempt to read in previous colors and locations
	NSMutableArray *colors = [[NSUserDefaults standardUserDefaults] objectForKey:@"colors"];
	NSMutableArray *locs = [[NSUserDefaults standardUserDefaults] objectForKey:@"locs"];
	
	// Add the flowers to random points on the screen	
	for (int i = 0; i < MAXFLOWERS; i++)
	{
		
		NSString *whichFlower = [[NSArray arrayWithObjects:@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png", nil] objectAtIndex:(random() % 3)];
		if (colors && ([colors count] == MAXFLOWERS)) whichFlower = [colors objectAtIndex:i];
		
		DragView *dragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		dragger.center = randomPoint();
		dragger.userInteractionEnabled = YES;
		dragger.whichFlower = whichFlower;
		if (locs && ([locs count] == MAXFLOWERS)) dragger.frame = CGRectFromString([locs objectAtIndex:i]);
		
		[backdrop addSubview:dragger];
		[dragger release];
	}
}

- (void) restart
{
	UIView *backdrop = [self.view viewWithTag:201];
	for (UIView *view in [backdrop subviews])
		[view removeFromSuperview];
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"colors"];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"locs"];
	
	[self loadFlowersInView:backdrop];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Restart", @selector(restart));
	srandom(time(0));
	
	// Add backdrop which will bound the movement for the flowers
	UIView *backdrop = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 282.0f)];
	backdrop.backgroundColor = [UIColor blackColor];
	backdrop.center = CGPointMake(160.0f, 140.0f);
	backdrop.tag = 201;

	[self loadFlowersInView:backdrop]; // load flowers

	[self.view  addSubview:backdrop];
	[backdrop release];
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
	[self.tbvc updateDefaults]; // update the defaults on quit
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
