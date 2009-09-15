/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <CLLocationManagerDelegate>
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
	CLLocationManager *locManager;
	NSObject *vs;
	NSDate *lockout;
}
@property (retain) NSMutableString *log;
@property (retain) CLLocationManager *locManager;
@property (retain) NSDate *lockout;
@end

@implementation TestBedViewController
@synthesize log;
@synthesize locManager;
@synthesize lockout;

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	textView.text = self.log;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	[self doLog:@"Location manager error: %@", [error description]];
	return;
}

- (void) report: (NSString *) aString
{
	// Only allow this method to run every five seconds
	if (!self.lockout) 
		self.lockout = [NSDate dateWithTimeIntervalSinceNow:5.0f];
	else if ([[NSDate date] timeIntervalSinceDate:self.lockout] < 0.0f) return;
	self.lockout = [NSDate dateWithTimeIntervalSinceNow:5.0f];
	
	// DO NOT USE THIS IN APP STORE APPLICATIONS
	[vs performSelector:@selector(startSpeakingString:) withObject:aString];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if (newLocation.speed > 0.0f)
	{
		NSString *speedFeedback = [NSString stringWithFormat:@"Speed is %0.1f miles per hour", 2.23693629 * newLocation.speed];
		[self report:speedFeedback];
		[self doLog:speedFeedback];
	}
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;

	self.log = [NSMutableString string];
	[self doLog:@"Starting location manager"];
	
	self.locManager = [[[CLLocationManager alloc] init] autorelease];
	if (!self.locManager.locationServicesEnabled)
	{
		[self doLog:@"User has opted out of location services"];
		return;
	}

	self.locManager.delegate = self;
	self.locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[self.locManager startUpdatingLocation];
	
	// DO NOT USE THIS IN YOUR APPLICATIONS!
	vs = [[NSClassFromString(@"VSSpeechSynthesizer") alloc] init];
	[self performSelector:@selector(report:) withObject:@"Ready to go" afterDelay:1.0f];
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
