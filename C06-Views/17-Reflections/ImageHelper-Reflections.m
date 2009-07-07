/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

#import "ImageHelper-Reflections.h"

@implementation ImageHelper
+ (CGImageRef) createGradientImage: (CGSize)size
{
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
    
	// Create gradient in gray device color space
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);

	// Draw the linear gradient
	CGPoint p1 = CGPointZero;
	CGPoint p2 = CGPointMake(0, size.height);
	CGContextDrawLinearGradient(context, gradient, p1, p2, kCGGradientDrawsAfterEndLocation);
	
	// Return the CGImage
	CGImageRef theCGImage = CGBitmapContextCreateImage(context);
	CFRelease(gradient);
	CGContextRelease(context);
    return theCGImage;
}

+ (UIImage *) reflectionOfView: (UIView *)theView withPercent: (CGFloat) percent
{
	// Retain the width but shrink the height
	CGSize size = CGSizeMake(theView.frame.size.width, theView.frame.size.height * percent);

	// Shrink the view
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[theView.layer renderInContext:context];
	UIImage *partialimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	// build the mask
	CGImageRef mask = [ImageHelper createGradientImage:size];
	CGImageRef ref = CGImageCreateWithMask(partialimg.CGImage, mask);
	UIImage *theImage = [UIImage imageWithCGImage:ref];
	CGImageRelease(ref);
	CGImageRelease(mask);
	return theImage;
}

const CGFloat kReflectDistance = 10.0f;

+ (void) addReflectionToView: (UIView *) theView
{
	theView.clipsToBounds = NO;
	UIImageView *reflection = [[UIImageView alloc] initWithImage:[ImageHelper reflectionOfView:theView withPercent: 0.45f]];
	CGRect frame = reflection.frame;
	frame.origin = CGPointMake(0.0f, theView.frame.size.height + kReflectDistance);
	reflection.frame = frame;
	[theView addSubview:reflection];
	[reflection release];
}

const CGFloat kReflectPercent = 0.5f;
const CGFloat kReflectOpacity = 0.5f;

+ (void) addSimpleReflectionToView: (UIView *) theView
{
	CALayer *reflectionLayer = [CALayer layer];
	reflectionLayer.contents = [theView layer].contents;
	reflectionLayer.opacity = kReflectOpacity;
	reflectionLayer.frame = CGRectMake(0.0f, 0.0f, theView.frame.size.width, theView.frame.size.height * kReflectPercent);
	CATransform3D stransform = CATransform3DMakeScale(1.0f, -1.0f, 1.0f);
	CATransform3D transform = CATransform3DTranslate(stransform, 0.0f, -(kReflectDistance + theView.frame.size.height), 0.0f);
	reflectionLayer.transform = transform;
	reflectionLayer.sublayerTransform = reflectionLayer.transform;
	[[theView layer] addSublayer:reflectionLayer];
}
@end