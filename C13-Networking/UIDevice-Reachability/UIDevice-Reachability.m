/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#include <unistd.h>
#include <sys/sysctl.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <ifaddrs.h>

#import "UIDevice-Reachability.h"
#import "NetReachability.h"
#import "wwanconnect.h"

#if ! defined(IFT_ETHER)
#define IFT_ETHER 0x6	// Ethernet CSMACD
#endif

@implementation UIDevice (Reachability)

#pragma mark Class IP and Host Utilities
+ (NSString *) stringFromAddress: (const struct sockaddr *) address
{
	if(address && address->sa_family == AF_INET) {
		const struct sockaddr_in* sin = (struct sockaddr_in*) address;
		return [NSString stringWithFormat:@"%@:%d", [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)], ntohs(sin->sin_port)];
	}
	
	return nil;
}

// Direct from Apple. Thank you Apple
+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
	if (!IPAddress || ![IPAddress length]) {
		return NO;
	}
	
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

+ (NSString *) hostname
{
	char baseHostName[255];
	int success = gethostname(baseHostName, 255);
	if (success != 0) return nil;
	baseHostName[255] = '\0';
	
    #if !TARGET_IPHONE_SIMULATOR
	return [NSString stringWithFormat:@"%s.local", baseHostName];
    #else
 	return [NSString stringWithFormat:@"%s", baseHostName];
    #endif
}

+ (NSString *) getIPAddressForHost: (NSString *) theHost
{
	struct hostent *host = gethostbyname([theHost UTF8String]);
    if (!host) {herror("resolv"); return NULL; }
	struct in_addr **list = (struct in_addr **)host->h_addr_list;
	NSString *addressString = [NSString stringWithCString:inet_ntoa(*list[0])];
	return addressString;
}


+ (NSString *) localIPAddress
{
	struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if (!host) {herror("resolv"); return nil;}
    struct in_addr **list = (struct in_addr **)host->h_addr_list;
	return [NSString stringWithCString:inet_ntoa(*list[0])];
}

// Matt Brown's get WiFi IP addy solution
// Author gave permission to use in Cookbook under cookbook license
// http://mattbsoftware.blogspot.com/2009/04/how-to-get-ip-address-of-iphone-os-v221.html
+ (NSString *) localWiFiIPAddress
{
	BOOL success;
	struct ifaddrs * addrs;
	const struct ifaddrs * cursor;
	
	success = getifaddrs(&addrs) == 0;
	if (success) {
		cursor = addrs;
		while (cursor != NULL) {
			// the second test keeps from picking up the loopback address
			if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0) 
			{
				NSString *name = [NSString stringWithUTF8String:cursor->ifa_name];
				if ([name isEqualToString:@"en0"])  // Wi-Fi adapter
					return [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
			}
			cursor = cursor->ifa_next;
		}
		freeifaddrs(addrs);
	}
	return nil;
}

+ (NSString *) whatismyipdotcom
{
	NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://www.whatismyip.com/automation/n09230945.asp"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:1 error:&error];
	return ip ? ip : [error localizedDescription];
}

#pragma mark Checking Connections
+ (BOOL) activeWLAN
{
	return ([UIDevice localWiFiIPAddress] != nil);
}

+ (BOOL) activeWWAN
{
	NetReachability *nr = [[[NetReachability alloc] initWithDefaultRoute:YES] autorelease];
	return ([nr isReachable] && [nr isUsingCell]);
}

+ (BOOL) networkAvailable
{
	NetReachability *nr = [[[NetReachability alloc] initWithDefaultRoute:YES] autorelease];
	return [nr isReachable];
}

#pragma mark WiFi Check and Alert
+ (void) showAlert: (id) formatstring,...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

+ (BOOL) performWiFiCheck
{
	NetReachability *nr = [[[NetReachability alloc] initWithDefaultRoute:YES] autorelease];
	if (![nr isReachable] || ([nr isReachable] && [nr isUsingCell]))
	{
		[self performSelector:@selector(showAlert:) withObject:@"This application requires WiFi. Please enable WiFi in Settings and run this application again." afterDelay:0.5f];
		return NO;
	}
	return YES;
}


#pragma mark Forcing WWAN connection. Courtesy of Apple. Thank you Apple.
MyStreamInfoPtr	myInfoPtr;
static void myClientCallback(void *refCon)
{
	int  *val = (int*)refCon;
	printf("myClientCallback entered - value from refCon is %d\n", *val);
}

+ (BOOL) forceWWAN
{
	int value = 0;
	myInfoPtr = (MyStreamInfoPtr) StartWWAN(myClientCallback, &value);
	NSLog(@"%@", myInfoPtr ? @"Started WWAN" : @"Failed to start WWAN");
	return (!(myInfoPtr == NULL));
}

+ (void) shutdownWWAN
{
	if (myInfoPtr) StopWWAN((MyInfoRef) myInfoPtr);
}

@end