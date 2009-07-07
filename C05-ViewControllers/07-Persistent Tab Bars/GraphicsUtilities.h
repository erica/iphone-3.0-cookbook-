/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface GraphicsUtilities : NSObject
+ (CGContextRef) newBitmapContextWithWidth: (int) pixelsWide andHeight:(int) pixelsHigh;
+ (void) addRoundedRect: (CGRect) rect toContext:(CGContextRef) context withWidth:(float) ovalWidth andHeight:(float) ovalHeight;
@end


