/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIView-SubviewGeometry.h"

// This is a private version of the function that appears in my UIView Frame category
// It's included here as a private function to avoid requiring the other file
CGRect rectWithCenter(CGRect rect, CGPoint center)
{
	CGRect newrect = CGRectZero;
	newrect.origin.x = center.x-CGRectGetMidX(rect);
	newrect.origin.y = center.y-CGRectGetMidY(rect);
	newrect.size = rect.size;
	return newrect;
}

@implementation UIView (SubviewGeometry)
#pragma mark Bounded Placement
- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInsets: (UIEdgeInsets) insets
{
	CGRect container = UIEdgeInsetsInsetRect(aView.bounds, insets);
	return CGRectContainsRect(container, rectWithCenter(self.frame, aCenter));
}

- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView withInset: (float) inset
{
	UIEdgeInsets insets = UIEdgeInsetsMake(inset, inset, inset, inset);
	return [self canMoveToCenter:aCenter inView:aView withInsets:insets];
}

- (BOOL) canMoveToCenter: (CGPoint) aCenter inView: (UIView *) aView
{
	return [self canMoveToCenter:aCenter inView:aView withInset:0];
}

#pragma mark Percent Displacement
// Move view into place as a percentage-based displacement
- (CGPoint) centerInView: (UIView *) aView withHorizontalPercent: (float) h withVerticalPercent: (float) v
{
	// Move in by the inset amount and then by size of the subview
	CGRect baseRect = aView.bounds;
	CGRect subRect = CGRectInset(baseRect, self.frame.size.width / 2.0f, self.frame.size.height / 2.0f);
	
	// Return a point that is h% horizontal and v% vertical
	float px = (float)(h * subRect.size.width);
	float py = (float)(v * subRect.size.height);
	return CGPointMake(px + subRect.origin.x, py + subRect.origin.y);
}

- (CGPoint) centerInSuperviewWithHorizontalPercent: (float) h withVerticalPercent: (float) v
{
	return [self centerInView:self.superview withHorizontalPercent:h withVerticalPercent:v];
}

#pragma mark Random
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

- (void) moveToRandomLocationInView: (UIView *) aView animated: (BOOL) animated
{
	if (!animated)
	{
		self.center = [self randomCenterInView:aView withInset:5];
		return;
	}
	
	// Why 0.3f seconds? Because that is the time used to display a keyboard
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.3f];
	
	self.center = [self randomCenterInView:aView withInset:5];
	
	[UIView commitAnimations];
}

- (void) moveToRandomLocationInSuperviewAnimated: (BOOL) animated
{
	[self moveToRandomLocationInView:self.superview animated:animated];
}

@end

