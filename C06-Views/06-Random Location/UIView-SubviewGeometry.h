/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface UIView (SubviewGeometry)
// Test whether view fits in its superview at a given center point
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInsets: (UIEdgeInsets) insets;
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInset: (float) inset;
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView;

// Slide view within superview using percents, e.g. 50% horizontal, 60% vertical
// View is guaranteed to fit within the parent.
- (CGPoint) centerInView: (UIView *) aView withHorizontalPercent: (float) h withVerticalPercent: (float) v;
- (CGPoint) centerInSuperviewWithHorizontalPercent: (float) h withVerticalPercent: (float) v;

// Move to a random point in the parent view, where child is guaranteed to
// fit inside the parent, and if specified, within an inset
- (CGPoint) randomCenterInView: (UIView *) aView withInsets: (UIEdgeInsets) insets;
- (CGPoint) randomCenterInView: (UIView *) aView withInset: (float) inset;

// Animate the movement to a random point within a particular view or the superview
// The child view is guaranteed to fit fully within the superview
- (void) moveToRandomLocationInView: (UIView *) aView animated: (BOOL) animated;
- (void) moveToRandomLocationInSuperviewAnimated: (BOOL) animated;
@end
