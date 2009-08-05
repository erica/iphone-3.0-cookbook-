/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@protocol TwitterOperationDelegate <NSObject>
- (void) doneTweeting: (NSString *) status;
@end

@interface TwitterOperation : NSOperation 
{
	KeychainItemWrapper *wrapper;
	NSString *theText;
	id <TwitterOperationDelegate> delegate;
}
@property (retain) KeychainItemWrapper *wrapper;
@property (retain) NSString *theText;
@property (retain) id delegate;
@end
