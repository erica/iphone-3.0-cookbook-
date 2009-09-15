/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "XMLParser.h"
#import "TreeNode.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define CURRENT_STRING	@"Current Location"

@interface MapAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@end
@implementation MapAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id) initWithCoordinate: (CLLocationCoordinate2D) aCoordinate
{
	if (self = [super init]) coordinate = aCoordinate;
	return self;
}

-(void) dealloc
{
	self.title = nil;
	self.subtitle = nil;
	[super dealloc];
}
@end

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
	CLLocationManager *locManager;
	CLLocation *current;
	IBOutlet MKMapView *mapView;
	
}
@property (retain) CLLocationManager *locManager;
@property (nonatomic, retain) CLLocation *current;
@end

@implementation TestBedViewController
@synthesize locManager;
@synthesize current;

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"Location manager error: %@", [error description]);
}

// Update map when the user interacts with it
- (void)mapView:(MKMapView *)aMapView regionDidChangeAnimated:(BOOL)animated
{
	// Gather annotations
	MapAnnotation *annotation;
	NSMutableArray *annotations = [NSMutableArray array];
	self.title = @"Searching...";
	
	// Add a current location annotation
	if (self.current)
	{
		annotation = [[[MapAnnotation alloc] initWithCoordinate:self.current.coordinate] autorelease];
		annotation.title = CURRENT_STRING;
		[annotations addObject:annotation];
	}
	
	// Clean up the map
	[mapView removeAnnotations:mapView.annotations];
	
	// fetch all the new locations from outside.in, while showing the network indicator
	// delayed selector allows title to update in a timely manner during the network operation
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self performSelector:@selector(setTitle:) withObject:@"Contacting Outside.in..." afterDelay:0.1f];
	NSString *urlstring = [NSString stringWithFormat:@"http://api.outside.in/radar.xml?lat=%f&lng=%f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude];
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlstring]];
	printf("Received %d bytes of data from outside.in\n", data.length);

	// Check to see if we got valid data
	NSString *xml = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if ([xml rangeOfString:@"places"].location == NSNotFound) 
	{
		// clean up and return
		[self performSelector:@selector(setTitle:) withObject:@"No locations found" afterDelay:0.1f];
		[mapView addAnnotations:annotations];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		return;
	}

	// If so, parse the data and find the place information
	TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:data];
	NSString *newtitle = [NSString stringWithFormat:@"%d location(s) found", [[root objectsForKey:@"places"] count]];
	[self performSelector:@selector(setTitle:) withObject:newtitle afterDelay:0.1f];

	// Add an annotation for each "place", using the coordinates, name and URL
	for (TreeNode *node in [root objectsForKey:@"place"])
	{
		// extract the coordinates
		NSArray *coords = [[node leafForKey:@"georss:point"] componentsSeparatedByString:@" "];
		if (coords.count < 2) continue;
		CLLocationCoordinate2D coord;
		coord.latitude = [[coords objectAtIndex:0] floatValue];
		coord.longitude = [[coords objectAtIndex:1] floatValue];
		
		// Create the annotation
		annotation = [[[MapAnnotation alloc] initWithCoordinate:coord] autorelease];
		annotation.title = [node leafForKey:@"name"];
		annotation.subtitle = [node leafForKey:@"url"];
		
		// Add it
		[annotations addObject:annotation];
	}
	
	// clean up the root
	[root teardown];
	
	// Stop showing the network indicator and add the annotations
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[mapView addAnnotations:annotations];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	// disable further location for the moment
	self.locManager.delegate = nil;
	[self.locManager stopUpdatingLocation];

	// Set the current location
	self.current = newLocation;
	
	// Set the map to that location and allow user interaction
	mapView.region = MKCoordinateRegionMake(newLocation.coordinate, MKCoordinateSpanMake(0.02f, 0.02f));
	mapView.zoomEnabled = YES;
	
	// restore find me button
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Find Me", @selector(findme));
}

// Perform user-request for location
- (void) findme
{
	// disable right button
	self.navigationItem.rightBarButtonItem = nil;
	self.title = @"Searching for location...";
	
	// Search for location
	self.locManager.delegate = self;
	[self.locManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	MapAnnotation *annotation = view.annotation;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:annotation.subtitle]];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	// Initialize each view
	for (MKPinAnnotationView *mkaview in views)
	{
		// The current location does not get a button
		if ([mkaview.annotation.title isEqualToString:CURRENT_STRING]) 
		{
			mkaview.pinColor = MKPinAnnotationColorPurple;
			mkaview.rightCalloutAccessoryView = nil;
			continue;
		}
		
		// All other locations are red with a button
		mkaview.pinColor = MKPinAnnotationColorRed;
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		mkaview.rightCalloutAccessoryView = button;
	}
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
	else // User allows location calls via settings
	{
		self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Find Me", @selector(findme));
		mapView.delegate = self;
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
