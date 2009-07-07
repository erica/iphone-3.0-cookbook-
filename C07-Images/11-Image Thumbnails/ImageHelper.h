/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

#define SUPPPORTS_UNDOCUMENTED_APIS	1

@interface ImageHelper : NSObject 
// Create image
+ (UIImage *) imageFromView: (UIView *) theView;

// Base Image Fitting
+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize;
+ (UIImage *) unrotateImage: (UIImage *) image;

+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) size; // retain proportions, fit in size
+ (UIImage *) image: (UIImage *) image fitInView: (UIView *) view; 

+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) size; // center, no resize
+ (UIImage *) image: (UIImage *) image centerInView: (UIView *) view; 

+ (UIImage *) image: (UIImage *) image fillSize: (CGSize) size; // fill all pixels
+ (UIImage *) image: (UIImage *) image fillView: (UIView *) view; 

#if SUPPPORTS_UNDOCUMENTED_APIS
+ (UIImage *) image: (UIImage *) image withOrientation: (UIImageOrientation) orientation;
#endif
@end

