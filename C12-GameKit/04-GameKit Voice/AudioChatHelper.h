/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface AudioChatHelper : NSObject <GKPeerPickerControllerDelegate, GKSessionDelegate, GKVoiceChatClient>
{
	NSString *sessionID;
	GKSession *session;
	BOOL isConnected;
	UIViewController *viewController;
}

@property (retain) NSString *sessionID;
@property (retain) GKSession *session;
@property (assign) BOOL isConnected;
@property (retain) UIViewController *viewController;

+ (void) connect;
+ (void) disconnect;
+ (AudioChatHelper *) sharedInstance;
+ (void) assignViewController: (UIViewController *) aViewController;
@end
