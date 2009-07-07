/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define URLIMAGE(X) [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:X]]]
#define MAP_URL	@"http://maps.weather.com/images/maps/current/curwx_720x486.jpg"

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
	UIImage *weathermap;
}
@property (retain) UIImage *weathermap;
@end

@implementation TestBedViewController
@synthesize weathermap;

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return [self.view viewWithTag:201];
}

/*
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
}
*/

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.weathermap = URLIMAGE(MAP_URL);
	self.title = @"Weather Scroller";
	
	// Create the scroll view and set its content size and delegate
	UIScrollView *sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 284.0f)] autorelease];
	sv.contentSize = self.weathermap.size;
	sv.delegate = self;
	
	// Create an image view to hold the weather map and add it to the scroll view
	UIImageView *iv = [[[UIImageView alloc] initWithImage:self.weathermap] autorelease];
	iv.userInteractionEnabled = YES;
	iv.tag = 201;
	
	// Calculate and set the zoom scale values
	float minzoomx = sv.frame.size.width / self.weathermap.size.width;
	float minzoomy = sv.frame.size.height / self.weathermap.size.height;
	sv.minimumZoomScale = MIN(minzoomx, minzoomy);
	sv.maximumZoomScale = 3.0f;

	// Add in the subviews
	[sv addSubview:iv];
	[self.view addSubview:sv];
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
