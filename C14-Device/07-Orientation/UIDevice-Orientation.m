/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIDevice-Orientation.h"

@implementation UIDevice (Orientation)
- (BOOL) isLandscape
{
	return (self.orientation == UIDeviceOrientationLandscapeLeft) || (self.orientation == UIDeviceOrientationLandscapeRight);
}

- (BOOL) isPortrait
{
	return (self.orientation == UIDeviceOrientationPortrait) || (self.orientation == UIDeviceOrientationPortraitUpsideDown);
}

- (NSString *) orientationString
{
	switch ([[UIDevice currentDevice] orientation])
	{
		case UIDeviceOrientationUnknown: return @"Unknown";
		case UIDeviceOrientationPortrait: return @"Portrait"; 
		case UIDeviceOrientationPortraitUpsideDown: return @"Portrait Upside Down"; 
		case UIDeviceOrientationLandscapeLeft: return @"Landscape Left"; 
		case UIDeviceOrientationLandscapeRight: return @"Landscape Right"; 
		case UIDeviceOrientationFaceUp: return @"Face Up"; 
		case UIDeviceOrientationFaceDown: return @"Face Down"; 
		default: break;
	}
	return nil;
}
@end