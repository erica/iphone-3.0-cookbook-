/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ImageHelper.h"

@interface ImageHelper (ImageProcessing)
+ (UIImage *) convolveImage:(UIImage *)image withBlurRadius: (int) radius;
+ (UIImage *) convolveImageWithEdgeDetection: (UIImage *) image;
@end
