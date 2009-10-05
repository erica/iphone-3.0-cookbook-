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
#import "MapAnnotation.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define API_KEY	@"YOUR API KEY HERE" // please use your own API key, not mine
#define LOCATIONS [NSArray arrayWithObjects:@"White House", @"Big Chicken", @"LA Zoo", @"Big Hot Dog", @"Randy's Donuts", nil]
#define PIC_SIZE	32.0f

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{
	IBOutlet MKMapView *mapView;
	NSMutableDictionary *annotationDict;
	int whichItem;
}
@end

@implementation TestBedViewController
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	MapAnnotation *annotation = view.annotation;
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:annotation.urlstring]];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (MKPinAnnotationView *mkaview in views)
	{
		mkaview.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		
		UIImage *origimage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[(MapAnnotation *)mkaview.annotation picstring]]]];
		UIGraphicsBeginImageContext(CGSizeMake(PIC_SIZE, PIC_SIZE));
		[origimage drawInRect:CGRectMake(0.0f, 0.0f, PIC_SIZE, PIC_SIZE)];
		UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		mkaview.leftCalloutAccessoryView = [[[UIImageView alloc] initWithImage:img] autorelease];
	}
}

// Perform user-request for location
- (void) findme
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSString *whichLocation = [LOCATIONS objectAtIndex:whichItem];
	
	// Geocode the location
	[self performSelector:@selector(setTitle:) withObject:whichLocation afterDelay:0.1f];
	NSMutableString *urlstring = [NSMutableString string];
	[urlstring appendFormat:@"http://local.yahooapis.com/MapsService/V1/geocode?appid=%@", API_KEY];
	
	NSString *locationURLString;
	NSString *picstring;
	// All images courtesy of Wikipedia (http://en.wikipedia.org)
	// and under either Creative Commons Attribution or Public Domain
	switch (whichItem)
	{
		case 0:
			// White House
			[urlstring appendFormat:@"&street=Pennsylvania+Avenue&city=@Washington+DC"];
			locationURLString = @"http://en.wikipedia.org/wiki/White_house";
			picstring = @"http://upload.wikimedia.org/wikipedia/commons/a/af/WhiteHouseSouthFacade.JPG";
			break;
		case 1:
			// Big chicken
			[urlstring appendFormat:@"&street=12+Cobb+Parkway&city=Marietta&zip=30062"];
			locationURLString = @"http://en.wikipedia.org/wiki/Big_Chicken";
			picstring = @"http://upload.wikimedia.org/wikipedia/commons/e/ed/Thebigchicken.jpg";
			break;
		case 2:
			// LA Zoo
			[urlstring appendFormat:@"&street=5333+Zoo+Drive&city=Los+Angeles&zip=90027"];
			locationURLString = @"http://en.wikipedia.org/wiki/LA_Zoo";
			picstring = @"http://upload.wikimedia.org/wikipedia/en/c/c9/LAzoo.jpg";
			break;
		case 3:
			// Big Hot Dog
			[urlstring appendFormat:@"&street=10+Old+Stagecoach+Road&city=Baily&state=CO"];
			locationURLString = @"http://en.wikipedia.org/wiki/Coney_Island_Hot_Dog_Stand";
			picstring = @"http://upload.wikimedia.org/wikipedia/commons/e/ea/Coney_Island_2007.JPG";
			break;
		case 4:
			// Randy's Donuts
			[urlstring appendFormat:@"&street=4805+West+Manchester+Avenue&city=Inglewood&zip=90301"];
			locationURLString = @"http://en.wikipedia.org/wiki/Randy%27s_Donuts";
			picstring = @"http://upload.wikimedia.org/wikipedia/commons/1/1d/2008-0914-RandysDonuts.jpg";
		default:
			break;
	}
	NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlstring]];
	printf("Received %d bytes of data from Yahoo\n", data.length);
	
	// Recover the coordinate
	TreeNode *root = [[XMLParser sharedInstance] parseXMLFromData:data];
	CLLocationCoordinate2D coord;
	coord.latitude = [[root leafForKey:@"Latitude"] floatValue];
	coord.longitude = [[root leafForKey:@"Longitude"] floatValue];

	// Set up the map view
	mapView.region = MKCoordinateRegionMakeWithDistance(coord, 10000, 10000);
	mapView.zoomEnabled = YES;
	
	// Create the annotation if it is not in the dictionary
	if (![annotationDict objectForKey:whichLocation])
	{
		MapAnnotation *annotation = [[[MapAnnotation alloc] initWithCoordinate:coord] autorelease];
		annotation.title = whichLocation;
		annotation.urlstring = locationURLString;
		annotation.picstring = picstring;
		annotation.subtitle = [NSString stringWithFormat:@"%f, %f", coord.latitude, coord.longitude];
		[annotationDict setObject:annotation forKey:whichLocation];
		[mapView removeAnnotations:mapView.annotations];
		[mapView addAnnotations:[annotationDict allValues]];
	}
	
	whichItem = (whichItem + 1) % [LOCATIONS count];
	whichLocation = [LOCATIONS objectAtIndex:whichItem];
	self.navigationItem.rightBarButtonItem = BARBUTTON(whichLocation, @selector(findme));
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"White House", @selector(findme));
	annotationDict = [[NSMutableDictionary alloc] init]; // retain for entire app lifespan
	mapView.delegate = self;
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
