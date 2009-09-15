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

#define MAX_TIME	10

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
{
	CLLocationManager *locManager;
	IBOutlet MKMapView *mapView;
	CLLocation *bestLocation;
	int timespent;
}
@property (retain) CLLocationManager *locManager;
@property (retain) CLLocation *bestLocation;
@end

@implementation TestBedViewController
@synthesize locManager;
@synthesize bestLocation;

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location manager error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// Keep track of the best location found
	if (!self.bestLocation) self.bestLocation = newLocation;
	else if (newLocation.horizontalAccuracy <  bestLocation.horizontalAccuracy) self.bestLocation = newLocation;
	
	mapView.region = MKCoordinateRegionMake(self.bestLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f));
	mapView.showsUserLocation = YES;
	mapView.zoomEnabled = NO;
}

// Search for n seconds to get the best location during that time
- (void) tick: (NSTimer *) timer
{
	if (++timespent == MAX_TIME)
	{
		// Invalidate the timer
		[timer invalidate];
		
		// Stop the location task
		[self.locManager stopUpdatingLocation];
		self.locManager.delegate = nil;
		
		// Restore the find me button
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Find Me", @selector(findme));
		
		if (!self.bestLocation) 
		{
			// no location found
			self.title = @"";
			return;
		}

		// Note the accuracy in the title bar
		self.title = [NSString stringWithFormat:@"%0.1f meters", self.bestLocation.horizontalAccuracy];
		
		// Update the map and allow user interaction
		// [mapView setRegion:MKCoordinateRegionMake(self.bestLocation.coordinate, MKCoordinateSpanMake(0.005f, 0.005f)) animated:YES];
		[mapView setRegion:MKCoordinateRegionMakeWithDistance(self.bestLocation.coordinate, 500.0f, 500.0f) animated:YES];

		mapView.showsUserLocation = YES;
		mapView.zoomEnabled = YES;
	}
	else
		self.title = [NSString stringWithFormat:@"%d secs remaining", MAX_TIME - timespent];
}

// Perform user-request for location
- (void) findme
{
	// disable right button
	self.navigationItem.rightBarButtonItem = nil;
	
	// Search for the best location
	timespent = 0;
	self.bestLocation = nil;
	self.locManager.delegate = self;
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
