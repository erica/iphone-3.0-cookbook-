/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ImageHelper.h"
#import <QuartzCore/QuartzCore.h>

#if SUPPPORTS_UNDOCUMENTED_APIS
@interface UIImage (privateAPISForOrientation)
- (id)initWithCGImage:(struct CGImage *)fp8 imageOrientation:(int)fp12;
@end
#endif

@implementation ImageHelper

#pragma mark Create Image

// Screen shot the view
+ (UIImage *) imageFromView: (UIView *) theView
{
	UIGraphicsBeginImageContext(theView.frame.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[theView.layer renderInContext:context];
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

#pragma mark Base Image Utility
+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize
{
	CGFloat scale;
	CGSize newsize = thisSize;
	
	if (newsize.height && (newsize.height > aSize.height))
	{
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	if (newsize.width && (newsize.width >= aSize.width))
	{
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	
	return newsize;
}

#define MIRRORED ((image.imageOrientation == UIImageOrientationUpMirrored) || (image.imageOrientation == UIImageOrientationLeftMirrored) || (image.imageOrientation == UIImageOrientationRightMirrored) || (image.imageOrientation == UIImageOrientationDownMirrored))	
#define ROTATED90	((image.imageOrientation == UIImageOrientationLeft) || (image.imageOrientation == UIImageOrientationLeftMirrored) || (image.imageOrientation == UIImageOrientationRight) || (image.imageOrientation == UIImageOrientationRightMirrored))

+ (UIImage *) doUnrotateImage: (UIImage *) image
{
	CGSize size = image.size;
	if (ROTATED90) size = CGSizeMake(image.size.height, image.size.width);
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGAffineTransform transform = CGAffineTransformIdentity;

	// Rotate as needed
	switch(image.imageOrientation)
	{  
        case UIImageOrientationLeft:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformRotate(transform, M_PI / 2.0f);
			transform = CGAffineTransformTranslate(transform, 0.0f, -size.width);
			size = CGSizeMake(size.height, size.width);
			CGContextConcatCTM(context, transform);
            break;
        case UIImageOrientationRight: 
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformRotate(transform, -M_PI / 2.0f);
			transform = CGAffineTransformTranslate(transform, -size.height, 0.0f);
			size = CGSizeMake(size.height, size.width);
			CGContextConcatCTM(context, transform);
            break;
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformRotate(transform, M_PI);
			transform = CGAffineTransformTranslate(transform, -size.width, -size.height);
			CGContextConcatCTM(context, transform);
			break;
        default:  
			break;
    }
	

	if (MIRRORED)
	{
		// de-mirror
		transform = CGAffineTransformMakeTranslation(size.width, 0.0f);
		transform = CGAffineTransformScale(transform, -1.0f, 1.0f);
		CGContextConcatCTM(context, transform);
	}
	    
	// Draw the image into the transformed context and return the image
	[image drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}	

+ (UIImage *) unrotateImage: (UIImage *) image
{
	if (image.imageOrientation == UIImageOrientationUp) return image;
	return [ImageHelper doUnrotateImage:image];
}



// Proportionately resize, completely fit in view, no cropping
+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) viewsize
{
	// calculate the fitted size
	CGSize size = [ImageHelper fitSize:image.size inSize:viewsize];
	
	UIGraphicsBeginImageContext(viewsize);

	float dwidth = (viewsize.width - size.width) / 2.0f;
	float dheight = (viewsize.height - size.height) / 2.0f;
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (UIImage *) image: (UIImage *) image fitInView: (UIView *) view
{
	return [self image:image fitInSize:view.frame.size];
}

// No resize, may crop
+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) viewsize
{
	CGSize size = image.size;
	
	UIGraphicsBeginImageContext(viewsize);
	float dwidth = (viewsize.width - size.width) / 2.0f;
	float dheight = (viewsize.height - size.height) / 2.0f;
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width, size.height);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (UIImage *) image: (UIImage *) image centerInView: (UIView *) view
{
	return [self image:image centerInSize:view.frame.size];
}

// Fill every view pixel with no black borders, resize and crop if needed
+ (UIImage *) image: (UIImage *) image fillSize: (CGSize) viewsize

{
	CGSize size = image.size;
	
	CGFloat scalex = viewsize.width / size.width;
	CGFloat scaley = viewsize.height / size.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	UIGraphicsBeginImageContext(viewsize);
	
	CGFloat width = size.width * scale;
	CGFloat height = size.height * scale;
	
	float dwidth = ((viewsize.width - width) / 2.0f);
	float dheight = ((viewsize.height - height) / 2.0f);
	
	CGRect rect = CGRectMake(dwidth, dheight, size.width * scale, size.height * scale);
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
	
    return newimg;  
}

+ (UIImage *) image: (UIImage *) image fillView: (UIView *) view
{
	return [self image:image fillSize:view.frame.size];
}

#if SUPPPORTS_UNDOCUMENTED_APIS
+ (UIImage *) image: (UIImage *) image withOrientation: (UIImageOrientation) orientation
{
	UIImage *newimg = [[UIImage alloc] initWithCGImage:[image CGImage] imageOrientation:orientation];
	return [newimg autorelease];
}
#endif

@end


