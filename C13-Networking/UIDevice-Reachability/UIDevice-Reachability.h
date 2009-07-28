/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	1

@interface UIDevice (Reachability)
+ (NSString *) stringFromAddress: (const struct sockaddr *) address;
+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address;

+ (NSString *) hostname;
+ (NSString *) getIPAddressForHost: (NSString *) theHost;
+ (NSString *) localIPAddress;
+ (NSString *) localWiFiIPAddress;
+ (NSString *) whatismyipdotcom;
+ (BOOL) networkAvailable;
+ (BOOL) activeWLAN;
+ (BOOL) activeWWAN;
+ (BOOL) performWiFiCheck;
+ (BOOL) forceWWAN; // via Apple
+ (void) shutdownWWAN; // via Apple
@end