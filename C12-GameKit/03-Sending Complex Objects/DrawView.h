/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"

@interface DrawView : UIView <GameKitHelperDataDelegate>
{
	NSMutableArray *points;
	NSArray *foreignPoints;
	UIColor *currentColor;
}
@property (retain) NSMutableArray *points;
@property (retain) NSArray *foreignPoints;
@property (retain) UIColor *currentColor;
- (void) clear;
@end
