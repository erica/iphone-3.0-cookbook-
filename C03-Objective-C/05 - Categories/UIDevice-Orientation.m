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
		case UIDeviceOrientationUnknown: return @"Unknown"; break;
		case UIDeviceOrientationPortrait: return @"Portrait"; break;
		case UIDeviceOrientationPortraitUpsideDown: return @"Portrait Upside Down"; break;
		case UIDeviceOrientationLandscapeLeft: return @"Landscape Left"; break;
		case UIDeviceOrientationLandscapeRight: return @"Landscape Right"; break;
		case UIDeviceOrientationFaceUp: return @"Face Up"; break;
		case UIDeviceOrientationFaceDown: return @"Face Down"; break;
		default: break;
	}
	return nil;
}
@end
