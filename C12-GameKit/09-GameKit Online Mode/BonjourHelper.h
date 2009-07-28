/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TCPServer.h"
#import "TCPConnection.h"

@protocol BonjourHelperDataDelegate <NSObject>
@optional
-(void) connectionEstablished;
-(void) connectionLost;
-(void) sentData: (NSString *) errorMessage;
-(void) receivedData: (NSData *) data;
@end

@interface BonjourHelper : NSObject <TCPConnectionDelegate, TCPServerDelegate>
{
	TCPServer *server;	
	NSNetServiceBrowser *browser;
	TCPConnection *inConnection;
	TCPConnection *outConnection;

	NSString *sessionID;
	id <BonjourHelperDataDelegate> dataDelegate;
	UIViewController *viewController;
	
	BOOL isConnected;
	
	UIAlertView *hud;
}
@property (retain) TCPServer *server;
@property (retain) NSNetServiceBrowser *browser;
@property (retain) TCPConnection *inConnection;
@property (retain) TCPConnection *outConnection;

@property (retain) id dataDelegate;
@property (retain) UIViewController *viewController;
@property (retain) NSString *sessionID;
@property (assign) BOOL isConnected;
@property (retain) UIAlertView *hud;

+ (BonjourHelper *) sharedInstance;
+ (BOOL) performWiFiCheck;
+ (void) connect;
+ (void) disconnect;
+ (void) sendData: (NSData *) data;
+ (void) assignViewController: (UIViewController *) aViewController;
@end
