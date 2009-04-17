/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@interface APNSHelper : NSObject 
{
	NSString *deviceTokenID;
	NSData *certificateData;
}
@property (nonatomic, retain)	NSString *deviceTokenID;
@property (nonatomic, retain)	NSData *certificateData;

+ (APNSHelper *) sharedInstance;
- (BOOL) push: (NSString *) payload;
@end
