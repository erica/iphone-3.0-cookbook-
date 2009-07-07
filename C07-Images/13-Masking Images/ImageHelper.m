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

#pragma mark Bitmap Offsets
// ARGB Offset Helpers
NSUInteger alphaOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 0;}
NSUInteger redOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 1;}
NSUInteger greenOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 2;}
NSUInteger blueOffset(NSUInteger x, NSUInteger y, NSUInteger w){return y * w * 4 + x * 4 + 3;}


#pragma mark Functions that build contexts

// The data must be freed from this and the bitmap released
// Use free(CGBitmapContextGetData(context)); and CGContextRelease(context);
CGContextRef CreateARGBBitmapContext (CGSize size)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
	
    void *bitmapData = malloc(size.width * size.height * 4);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Error: Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
	
    CGContextRef context = CGBitmapContextCreate (bitmapData, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace );
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bitmapData);
		return NULL;
    }
	
    return context;
}

#pragma mark Context Utilities

// Fix the context when using image contexts because there are times you must live in quartzland
void FlipContextVertically(CGContextRef context, CGSize size)
{
	CGAffineTransform transform = CGAffineTransformIdentity;
	transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
	transform = CGAffineTransformTranslate(transform, 0.0f, -size.height);
	CGContextConcatCTM(context, transform);
}

// Add rounded rectangle to context
void addRoundedRectToContext(CGContextRef context, CGRect rect, CGSize ovalSize)
{
	if (ovalSize.width == 0.0f || ovalSize.height == 0.0f) 
	{
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
		CGContextClosePath(context);
		CGContextRestoreGState(context);
		return;
	}
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalSize.width, ovalSize.height);
	float fw = CGRectGetWidth(rect) / ovalSize.width;
	float fh = CGRectGetHeight(rect) / ovalSize.height;
	
	CGContextMoveToPoint(context, fw, fh/2); 
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); 
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

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

// Fill image with bits
+ (UIImage *) imageWithBits: (unsigned char *) bits withSize: (CGSize) size
{
	// Create a color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
		free(bits);
        return nil;
    }
	
    CGContextRef context = CGBitmapContextCreate (bits, size.width, size.height, 8, size.width * 4, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        fprintf (stderr, "Error: Context not created!");
        free (bits);
		CGColorSpaceRelease(colorSpace );
		return nil;
    }
	
    CGColorSpaceRelease(colorSpace );
	CGImageRef ref = CGBitmapContextCreateImage(context);
	free(CGBitmapContextGetData(context));
	CGContextRelease(context);
	
	UIImage *img = [UIImage imageWithCGImage:ref];
	CFRelease(ref);
	return img;
}

#pragma mark Contexts and Bitmaps
+ (unsigned char *) bitmapFromImage: (UIImage *) image
{
	CGContextRef context = CreateARGBBitmapContext(image.size);
    if (context == NULL) return NULL;
	
    CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
    CGContextDrawImage(context, rect, image.CGImage);
	unsigned char *data = CGBitmapContextGetData (context);
	CGContextRelease(context);
	return data;
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

// Centers the fit size in the frame
+ (CGRect) frameSize: (CGSize)thisSize inSize: (CGSize) aSize
{
	CGSize size = [self fitSize:thisSize inSize: aSize];
	float dWidth = aSize.width - size.width;
	float dHeight = aSize.height - size.height;
	
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, size.width, size.height);
}

+ (CGRect) fillSize: (CGSize) thisSize inSize: (CGSize) aSize
{
	CGFloat scalex = aSize.width / thisSize.width;
	CGFloat scaley = aSize.height / thisSize.height; 
	CGFloat scale = MAX(scalex, scaley);	
	
	CGFloat width = thisSize.width * scale;
	CGFloat height = thisSize.height * scale;
	
	float dwidth = ((aSize.width - width) / 2.0f);
	float dheight = ((aSize.height - height) / 2.0f);
	
	CGRect rect = CGRectMake(dwidth, dheight, thisSize.width * scale, thisSize.height * scale);
	return rect;
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
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:[ImageHelper frameSize:image.size inSize:viewsize]];
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

#pragma mark Paths

// Convenience function for rounded rect corners that hides built-in function
+ (void) addRoundedRect:(CGRect) rect toContext:(CGContextRef) context withOvalSize:(CGSize) ovalSize
{
	addRoundedRectToContext(context, rect, ovalSize);
}

+ (UIImage *) roundedImage: (UIImage *) image withOvalSize: (CGSize) ovalSize withInset: (CGFloat) inset
{
	
	UIGraphicsBeginImageContext(image.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
	addRoundedRectToContext(context, rect, ovalSize);
	CGContextClip(context);
	
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *) roundedImage: (UIImage *) image withOvalSize: (CGSize) ovalSize
{
	return [ImageHelper roundedImage:image withOvalSize:ovalSize withInset: 0.0f];
}

+ (UIImage *) roundedBacksplashOfSize: (CGSize)size andColor:(UIColor *) color withRounding: (CGFloat) rounding andInset: (CGFloat) inset
{
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rect = CGRectMake(inset, inset, size.width - 2.0f * inset, size.height - 2.0f * inset);
	addRoundedRectToContext(context, rect, CGSizeMake(rounding, rounding));
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillPath(context);
	CGContextClip(context);	
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newimg;
}

+ (UIImage *) ellipseImage: (UIImage *) image withInset: (CGFloat) inset
{
	
	UIGraphicsBeginImageContext(image.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
	CGContextAddEllipseInRect(context, rect);
	CGContextClip(context);
	
	[image drawInRect:rect];
	
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *) grayscaleImage: (UIImage *) image
{
	CGSize size = image.size;
	CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, rect, [image CGImage]);
	CGImageRef grayscale = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	UIImage *img = [UIImage imageWithCGImage:grayscale];
	CFRelease(grayscale);
	return img;
}

CGImageRef CreateMaskImage(UIImage *image)
{
	CGSize size = image.size;
	CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGImageAlphaNone);
	FlipContextVertically(context, size);
	CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, rect, [image CGImage]);
	CGImageRef maskRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	return maskRef;
}

+ (UIImage*) frameImage: (UIImage *) image withMask: (UIImage *) mask
{
	UIGraphicsBeginImageContext(mask.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Create the mask and clip to it
	CGRect rect = CGRectMake(0.0f, 0.0f, mask.size.width, mask.size.height);
	CGImageRef maskref = CreateMaskImage(mask);
 	CGContextClipToMask(context, rect, maskref);
	CFRelease(maskref);
	
	// Draw the image
	[image drawInRect:[ImageHelper fillSize:image.size inSize:mask.size]];
	
	// Return the new image
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;
}

#if SUPPPORTS_UNDOCUMENTED_APIS
+ (UIImage *) image: (UIImage *) image withOrientation: (UIImageOrientation) orientation
{
	UIImage *newimg = [[UIImage alloc] initWithCGImage:[image CGImage] imageOrientation:orientation];
	return [newimg autorelease];
}
#endif

@end


