/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#include "GraphicsUtilities.h"

@implementation GraphicsUtilities
+ (CGContextRef) newBitmapContextWithWidth: (int) pixelsWide andHeight:(int) pixelsHigh
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        free (bitmapData);
		CGColorSpaceRelease( colorSpace );
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace );
	
    return context;
}

+ (void) addRoundedRect: (CGRect) rect toContext:(CGContextRef) context withWidth:(float) ovalWidth andHeight:(float) ovalHeight
{
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth(rect) / ovalWidth;
	fh = CGRectGetHeight(rect) / ovalHeight;
	
	CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}
@end
