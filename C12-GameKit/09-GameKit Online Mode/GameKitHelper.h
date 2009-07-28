/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@protocol GameKitHelperDataDelegate <NSObject>
@optional
-(void) connectionEstablished;
-(void) connectionLost;
-(void) sentData: (NSString *) errorMessage;
-(void) receivedData: (NSData *) data;
@end


@interface GameKitHelper : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate>
{
	NSString *sessionID;
	id <GameKitHelperDataDelegate> dataDelegate;
	UIViewController *viewController;
	
	GKSession *session;
	BOOL isConnected;
}

@property (retain) id dataDelegate;
@property (retain) UIViewController *viewController;
@property (retain) NSString *sessionID;
@property (retain) GKSession *session;
@property (assign) BOOL isConnected;

+ (void) connect;
+ (void) disconnect;
+ (void) sendData: (NSData *) data;
+ (void) assignViewController: (UIViewController *) aViewController;

+ (GameKitHelper *) sharedInstance;
@end
