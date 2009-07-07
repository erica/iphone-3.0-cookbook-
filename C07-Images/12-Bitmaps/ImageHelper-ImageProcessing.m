/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ImageHelper-ImageProcessing.h"

@implementation ImageHelper (ImageProcessing)
+ (UIImage *) convolveImage:(UIImage *)image withBlurRadius: (int) radius
{
	int theheight = (int) image.size.height;
	int thewidth = (int) image.size.width;
	
	// Get input and output bits
	unsigned char *inbits = (unsigned char *)[ImageHelper bitmapFromImage:image];
	unsigned char *outbits = (unsigned char *)malloc(theheight * thewidth * 4);
	
	// Find the size of the square with radius radius
	int squared = 4 * radius * radius + 4 * radius + 1;
	
	// Iterate through each available pixel (leaving a radius-sized boundary)
	for (int y = radius; y < (theheight - radius); y++)
		for (int x = radius; x < (thewidth - radius); x++)
		{
			unsigned int sumr = 0;
			unsigned int sumg = 0;
			unsigned int sumb = 0;
			
			// Iterate through the mask, which is sum/size for blur
			for (int j = -1 * radius; j <= radius; j++)
				for (int i = -1 * radius; i <= radius; i++)
				{
					sumr += (unsigned char) inbits[redOffset(x+i, y+j, thewidth)];
					sumg += (unsigned char) inbits[greenOffset(x+i, y+j, thewidth)];
					sumb += (unsigned char) inbits[blueOffset(x+i, y+j, thewidth)];
				}
			
			// Assign the outbits
			outbits[redOffset(x, y, thewidth)] = (unsigned char) (sumr / squared);
			outbits[greenOffset(x, y, thewidth)] = (unsigned char) (sumg / squared);
			outbits[blueOffset(x, y, thewidth)] = (unsigned char) (sumb / squared);
			outbits[alphaOffset(x, y, thewidth)] = (unsigned char) 0xff;
		}
	
	free(inbits); // Release the original bitmap
	return [ImageHelper imageWithBits:outbits withSize:image.size];
}

+ (UIImage *) convolveImageWithEdgeDetection: (UIImage *) image
{
	int theheight = (int) image.size.height;
	int thewidth = (int) image.size.width;
	
	// Get input and output bits
	unsigned char *inbits = (unsigned char *)[ImageHelper bitmapFromImage:image];
	unsigned char *outbits = (unsigned char *)malloc(theheight * thewidth * 4);
	
	int radius = 1;
	
	// Iterate through each available pixel (leaving a radius-sized boundary)
	for (int y = radius; y < (theheight - radius); y++)
		for (int x = radius; x < (thewidth - radius); x++)
		{
			int sumr1 = 0, sumr2 = 0;
			int sumg1 = 0, sumg2 = 0;
			int sumb1 = 0, sumb2 = 0;
			
			// Basic Canny Edge Detection
			int matrix1[9] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
			int matrix2[9] = {-1, -2, -1, 0, 0, 0, 1, 2, 1};
			int offset = 0;
			for (int j = -radius; j <= radius; j++)
				for (int i = -radius; i <= radius; i++)
				{
					sumr1 += inbits[redOffset(x+i, y+j, thewidth)] * matrix1[offset];
					sumr2 += inbits[redOffset(x+i, y+j, thewidth)] * matrix2[offset];
					
					sumg1 += inbits[greenOffset(x+i, y+j, thewidth)] * matrix1[offset];
					sumg2 += inbits[greenOffset(x+i, y+j, thewidth)] * matrix2[offset];
					
					sumb1 += inbits[blueOffset(x+i, y+j, thewidth)] * matrix1[offset];
					sumb2 += inbits[blueOffset(x+i, y+j, thewidth)] * matrix2[offset];
					
					offset++;
				}
			
			// Assign the outbits
			int sumr = MIN(((ABS(sumr1) + ABS(sumr2)) / 2), 255);
			int sumg = MIN(((ABS(sumg1) + ABS(sumg2)) / 2), 255);
			int sumb = MIN(((ABS(sumb1) + ABS(sumb2)) / 2), 255);
			
			outbits[redOffset(x, y, thewidth)] = (unsigned char) sumr;
			outbits[greenOffset(x, y, thewidth)] = (unsigned char) sumg;
			outbits[blueOffset(x, y, thewidth)] = (unsigned char) sumb;
			outbits[alphaOffset(x, y, thewidth)] = (unsigned char) inbits[alphaOffset(x, y, thewidth)];
		}
	
	// Release the original bitmap
	free(inbits);
	return [ImageHelper imageWithBits:outbits withSize:image.size];
}
@end
