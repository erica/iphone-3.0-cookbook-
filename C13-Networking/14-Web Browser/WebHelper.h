/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "MIMEHelper.h"
#include <arpa/inet.h>
#include <netdb.h>

@protocol WebHelperDelegate <NSObject>
@optional
- (void) serviceCouldNotBeEstablished;
- (void) serviceWasEstablished;
- (void) serviceWasLost;
@end

#define BUFSIZE 8096

#define STATUS_OFFLINE	0
#define STATUS_ATTEMPT	1
#define STATUS_ONLINE	2

@interface WebHelper : NSObject 
{
	NSString		*cwd;
	id <WebHelperDelegate>	delegate;
	
	int				serverStatus;
	BOOL			isServing;
	int				listenfd;
	int				chosenPort;
	int				socketfd;
}
@property (retain) NSString *cwd;
@property (retain) id delegate;
@property (assign) BOOL isServing;
@property (assign) int chosenPort;

+ (WebHelper *) sharedInstance;
- (void) startService;
@end
