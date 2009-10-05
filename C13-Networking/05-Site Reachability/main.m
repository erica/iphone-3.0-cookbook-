/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@end

@implementation TestBedViewController
@synthesize log;

// Direct from Apple. Thank you Apple
- (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
    if (!IPAddress || ![IPAddress length]) return NO;
	
    memset((char *) address, sizeof(struct sockaddr_in), 0);
    address->sin_family = AF_INET;
    address->sin_len = sizeof(struct sockaddr_in);
	
    int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
    if (conversionResult == 0) {
		NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
        return NO;
    }
	
    return YES;
}

- (NSString *) getIPAddressForHost: (NSString *) theHost
{
	struct hostent *host = gethostbyname([theHost UTF8String]);
    if (!host) {herror("resolv"); return NULL; }
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
	return addressString;
}

- (BOOL) hostAvailable: (NSString *) theHost
{
	
    NSString *addressString = [self getIPAddressForHost:theHost];
    if (!addressString)
    {
        printf("Error recovering IP address from host name\n");
        return NO;
    }
	
    struct sockaddr_in address;
    BOOL gotAddress = [self addressFromString:addressString address:&address];
	
    if (!gotAddress)
    {
		printf("Error recovering sockaddr address from %s\n", [addressString UTF8String]);
        return NO;
    }
	
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&address);
    SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags =SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    return isReachable ? YES : NO;;
}

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

#define CHECK(SITE) [self doLog:@"• %@ : %@", SITE, [self hostAvailable:SITE] ? @"available" : @"not available"];

- (void) action: (UIBarButtonItem *) bbi
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	self.log = [NSMutableString string];
	CHECK(@"www.google.com");
	CHECK(@"www.ericasadun.com");
	CHECK(@"www.notverylikely.com");
	CHECK(@"192.168.0.108");
	CHECK(@"pearson.com");
	CHECK(@"www.pearson.com");
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
