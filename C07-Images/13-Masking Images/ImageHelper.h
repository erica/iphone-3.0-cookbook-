/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

// ARGB Offset Helpers
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w);
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w);

// This version mallocs an actual bitmap, so make sure you understand the memory issues:
// Use free(CGBitmapContextGetData(context)); and CGContextRelease(context);
CGContextRef CreateARGBBitmapContext (CGSize size);

#define SUPPPORTS_UNDOCUMENTED_APIS	1


@interface ImageHelper : NSObject 
// Create image
+ (UIImage *) imageFromView: (UIView *) theView;

// Bits
+ (UIImage *) imageWithBits: (unsigned char *) bits withSize: (CGSize) size;
+ (unsigned char *) bitmapFromImage: (UIImage *) image;

// Base Image Fitting
+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize;
+ (CGRect) frameSize: (CGSize)thisSize inSize: (CGSize) aSize;

+ (UIImage *) unrotateImage: (UIImage *) image;

+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) size; // retain proportions, fit in size
+ (UIImage *) image: (UIImage *) image fitInView: (UIView *) view; 

+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) size; // center, no resize
+ (UIImage *) image: (UIImage *) image centerInView: (UIView *) view; 

+ (UIImage *) image: (UIImage *) image fillSize: (CGSize) size; // fill all pixels
+ (UIImage *) image: (UIImage *) image fillView: (UIView *) view; 

// Paths
+ (void) addRoundedRect:(CGRect) rect toContext:(CGContextRef) context withOvalSize:(CGSize) ovalSize;
+ (UIImage *) roundedImage: (UIImage *) image withOvalSize: (CGSize) ovalSize withInset: (CGFloat) inset;
+ (UIImage *) roundedImage: (UIImage *) img withOvalSize: (CGSize) ovalSize;
+ (UIImage *) roundedBacksplashOfSize: (CGSize)size andColor:(UIColor *) color withRounding: (CGFloat) rounding andInset: (CGFloat) inset;
+ (UIImage *) ellipseImage: (UIImage *) image withInset: (CGFloat) inset;

// Masking
+ (UIImage *) frameImage: (UIImage *) image withMask: (UIImage *) mask;
+ (UIImage *) grayscaleImage: (UIImage *) image;

#if SUPPPORTS_UNDOCUMENTED_APIS
+ (UIImage *) image: (UIImage *) image withOrientation: (UIImageOrientation) orientation;
#endif
@end

