/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

@interface DragView : UIImageView
{
	CGPoint startLocation;
}
@end

@implementation DragView
- (id) initWithImage: (UIImage *) anImage
{
	if (self = [super initWithImage:anImage])
		self.userInteractionEnabled = YES;
	return self;
}

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
@end


@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
#define MAXFLOWERS 12

CGPoint randomPoint() 
{
	int half = 32; // half of flower size
	int freesize = 240 - 2 * half; // inner area
	return CGPointMake(random() % freesize + half, random() % freesize + half);
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	srandom(time(0));
	
	// Add backdrop which will bound the movement for the flowers
	UIView *backdrop = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 282.0f)];
	backdrop.backgroundColor = [UIColor blackColor];
	backdrop.center = CGPointMake(160.0f, 140.0f);
	
	// Add the flowers to random points on the screen	
	for (int i = 0; i < MAXFLOWERS; i++)
	{
		NSString *whichFlower = [[NSArray arrayWithObjects:@"blueFlower.png", @"pinkFlower.png", @"orangeFlower.png", nil] objectAtIndex:(random() % 3)];
		DragView *dragger = [[DragView alloc] initWithImage:[UIImage imageNamed:whichFlower]];
		dragger.center = randomPoint();
		dragger.userInteractionEnabled = YES;
		[backdrop addSubview:dragger];
		[dragger release];
	}

	[self.view  addSubview:backdrop];
	[backdrop release];
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
