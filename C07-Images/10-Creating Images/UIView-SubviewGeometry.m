/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIView-SubviewGeometry.h"
@implementation UIView (SubviewGeometry)
// Make sure you've run srandom() elsewhere in the program
// Thanks to August Joki and manitoba98
- (CGPoint) randomCenterInView: (UIView *) aView withInsets: (UIEdgeInsets) insets
{
	// Move in by the inset amount and then by size of the subview
	CGRect innerRect = UIEdgeInsetsInsetRect([aView bounds], insets);
	CGRect subRect = CGRectInset(innerRect, self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
	
	// Return a random point
	float rx = (float)(random() % (int)floor(subRect.size.width));
	float ry = (float)(random() % (int)floor(subRect.size.height));
	return CGPointMake(rx + subRect.origin.x, ry + subRect.origin.y);
}

- (CGPoint) randomCenterInView: (UIView *) aView withInset: (float) inset
{
	UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
	return [self randomCenterInView:aView withInsets:insets];
}

@end