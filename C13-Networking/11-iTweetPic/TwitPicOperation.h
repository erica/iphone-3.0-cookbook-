/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@protocol TwitPicOperationDelegate <NSObject>
- (void) doneTweeting: (NSString *) status;
@end

@interface TwitPicOperation : NSOperation 
{
	KeychainItemWrapper *wrapper;
	UIImage *theImage;
	id <TwitPicOperationDelegate> delegate;
}
@property (retain) KeychainItemWrapper *wrapper;
@property (retain) UIImage *theImage;
@property (retain) id delegate;
@end
