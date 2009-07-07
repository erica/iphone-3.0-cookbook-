/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface ModalHUD : NSObject
+ (void) showHUD:(id)formatstring,...;
+ (void) dismiss;
@end