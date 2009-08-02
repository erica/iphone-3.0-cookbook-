/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <SystemConfiguration/SystemConfiguration.h>
#include <netdb.h>
#import <dlfcn.h>
#import "UIDevice-Reachability.h"

@implementation UIDevice (Reachability)
SCNetworkConnectionFlags connectionFlags;
SCNetworkReachabilityRef reachability;

#pragma mark Checking Connections
+ (void) pingReachabilityInternal
{
	if (!reachability)
	{
		BOOL ignoresAdHocWiFi = NO;
		struct sockaddr_in ipAddress;
		bzero(&ipAddress, sizeof(ipAddress));
		ipAddress.sin_len = sizeof(ipAddress);
		ipAddress.sin_family = AF_INET;
		ipAddress.sin_addr.s_addr = htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM);
		
		reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&ipAddress);
		CFRetain(reachability);
	}
	
	// Recover reachability flags
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(reachability, &connectionFlags);
	if (!didRetrieveFlags) printf("Error. Could not recover network reachability flags\n");
}

#pragma mark Monitoring reachability
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkConnectionFlags flags, void* info)
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	[(id)info performSelector:@selector(reachabilityChanged)];
	[pool release];
}

+ (BOOL) scheduleReachabilityWatcher: (id) watcher
{
	if (![watcher conformsToProtocol:@protocol(ReachabilityWatcher)]) 
	{
		NSLog(@"Watcher must conform to ReachabilityWatcher protocol. Cannot continue.");
		return NO;
	}
	
	[self pingReachabilityInternal];

	SCNetworkReachabilityContext context = {0, watcher, NULL, NULL, NULL};
	if(SCNetworkReachabilitySetCallback(reachability, ReachabilityCallback, &context)) 
	{
		if(!SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes)) 
		{
			NSLog(@"Error: Could not schedule reachability");
			SCNetworkReachabilitySetCallback(reachability, NULL, NULL);
			return NO;
		}
	} 
	else 
	{
		NSLog(@"Error: Could not set reachability callback");
		return NO;
	}
	
	return YES;
}

+ (void) unscheduleReachabilityWatcher
{
	SCNetworkReachabilitySetCallback(reachability, NULL, NULL);
	if (SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopCommonModes))
		NSLog(@"Unscheduled reachability");
	else
		NSLog(@"Error: Could not unschedule reachability");
	
	CFRelease(reachability);
	reachability = nil;
}

#ifdef SUPPORTS_UNDOCUMENTED_API
#define SBSERVPATH  "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"
#define UIKITPATH "/System/Library/Framework/UIKit.framework/UIKit"

// Don't use this code in real life, boys and girls. It is not App Store friendly.
// It is, however, really nice for testing callbacks
+ (void) setAPMode: (BOOL) yorn
{
	mach_port_t *thePort;
	void *uikit = dlopen(UIKITPATH, RTLD_LAZY);
	int (*SBSSpringBoardServerPort)() = dlsym(uikit, "SBSSpringBoardServerPort");
	thePort = (mach_port_t *)SBSSpringBoardServerPort(); 
	dlclose(uikit);
	
	// Link to SBSetAirplaneModeEnabled
	void *sbserv = dlopen(SBSERVPATH, RTLD_LAZY);
	int (*setAPMode)(mach_port_t* port, BOOL yorn) = dlsym(sbserv, "SBSetAirplaneModeEnabled");
	setAPMode(thePort, yorn);
	dlclose(sbserv);
}
#endif
@end