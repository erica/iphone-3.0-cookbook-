/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License for anything not specifically marked as developed by a third party.
 Apple's code excluded.
 Use at your own risk
 */

#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	1

@protocol ReachabilityWatcher <NSObject>
- (void) reachabilityChanged;
@end


@interface UIDevice (Reachability)
+ (BOOL) scheduleReachabilityWatcher: (id) watcher;
+ (void) unscheduleReachabilityWatcher;

#ifdef SUPPORTS_UNDOCUMENTED_API
// Don't use this code in real life, boys and girls. It is not App Store friendly.
// It is, however, really nice for testing callbacks
+ (void) setAPMode: (BOOL) yorn;
#endif

@end