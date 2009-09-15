/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#define MAX_TIME	5

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
{
	CLLocationManager *locManager;
	IBOutlet MKMapView *mapView;
}
@property (retain) CLLocationManager *locManager;
@end

@implementation TestBedViewController
@synthesize locManager;

// Search for n seconds to get the best location during that time
- (void) tick: (NSTimer *) timer
{
	if (mapView.userLocation)
		[mapView setRegion:MKCoordinateRegionMake(mapView.userLocation.location.coordinate, MKCoordinateSpanMake(0.005f, 0.005f)) animated:NO];
	mapView.userLocation.title = @"Location Coordinates";
	mapView.userLocation.subtitle = [NSString stringWithFormat:@"%f, %f", mapView.userLocation.location.coordinate.latitude, mapView.userLocation.location.coordinate.longitude];
}

// Perform user-request for location
- (void) findme
{
	self.navigationItem.rightBarButtonItem = nil;
	[self.locManager startUpdatingLocation];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;

	self.locManager = [[[CLLocationManager alloc] init] autorelease];
	if (!self.locManager.locationServicesEnabled)
	{
		NSLog(@"User has opted out of location services");
		return;
	}
	else 
	{
		// User generally allows location calls
		self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Find Me", @selector(findme));
		mapView.showsUserLocation = YES;
		mapView.zoomEnabled = NO;
	}
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
