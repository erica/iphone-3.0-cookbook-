/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

/*
 
 This version of GameKit helper is a little extra to demonstrate how to avoid
 using the built-in peer picker. It's pretty bare bones but hopefully the idea will
 get across.
 
 */

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
	GKSession *mySession;
	int connectStage;
	IBOutlet UIViewController <GameKitHelperDataDelegate> *viewController;
}

@property (retain) NSString *sessionID;
@property (retain) GKSession *mySession;
@property (retain) UIViewController *viewController;

- (void) disconnect;
- (void) sendData: (NSData *) data;
- (BOOL) isConnected;
@end
