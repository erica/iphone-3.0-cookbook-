/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIDevice (Hardware)
+ (NSString *) platform;
+ (NSUInteger) cpuFrequency;
+ (NSUInteger) busFrequency;
+ (NSUInteger) totalMemory;
+ (NSUInteger) userMemory;
@end