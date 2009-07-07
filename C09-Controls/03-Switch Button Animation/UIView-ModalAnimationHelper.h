/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIView (ModalAnimationHelper)
+ (void) commitModalAnimations;
+ (void) modalAnimationWithTarget: (id) target selector:(SEL) selector object:(id) object duration:(float) duration;
@end
