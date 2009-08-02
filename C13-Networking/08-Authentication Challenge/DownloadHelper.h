/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DownloadHelperDelegate <NSObject>
@optional
- (void) didReceiveData: (NSData *) theData;
- (void) didReceiveFilename: (NSString *) aName;
- (void) dataDownloadFailed: (NSString *) reason;
- (void) dataDownloadAtPercent: (NSNumber *) aPercent;
@end

@interface DownloadHelper : NSObject 
{
	NSURLResponse *response;
	NSMutableData *data;
	NSString *urlString;
	id <DownloadHelperDelegate> delegate;
	NSString *password;
	NSString *username;
}
@property (retain) NSURLResponse *response;
@property (retain) NSMutableData *data;
@property (retain) NSString *urlString;
@property (retain) id delegate;
@property (retain) NSString *username;
@property (retain) NSString *password;

+ (DownloadHelper *) sharedInstance;
+ (void) download:(NSString *) aURLString;
@end
