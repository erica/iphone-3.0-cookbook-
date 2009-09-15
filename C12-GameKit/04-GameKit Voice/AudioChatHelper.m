
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "AudioChatHelper.h"
#import <AVFoundation/AVFoundation.h>

#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

@implementation AudioChatHelper
@synthesize sessionID;
@synthesize session;
@synthesize isConnected;
@synthesize viewController;

static AudioChatHelper *sharedInstance = nil;

+ (AudioChatHelper *) sharedInstance
{
	if(!sharedInstance) {
		sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	[[GKVoiceChatService defaultVoiceChatService] receivedData:data fromParticipantID:peer]; 
}

- (NSString *)participantID 
{ 
    return self.session.peerID; 
}

- (void) startConnection
{
	if (!self.isConnected)
	{
		GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
		picker.delegate = self; 
		picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
		[picker show]; 
		if (self.viewController) 
			self.viewController.navigationItem.rightBarButtonItem = nil;
	}
}

- (void) peerPickerControllerDidCancel: (GKPeerPickerController *)picker
{
	[picker release];
	if (self.viewController) 
		self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(startConnection));
}

- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID 
{ 
    [self.session sendData: data toPeers:[NSArray arrayWithObject: participantID] withDataMode: GKSendDataReliable error: nil];
} 

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session{ 

	[picker dismiss];
	[picker release];
	isConnected = YES;
	[self.session setDataReceiveHandler:self withContext:nil];
	
	NSError *error;
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	
	if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error setting the AV play/record category: %@", [error localizedDescription]);
		showAlert(@"Could not establish an Audio Connection. Sorry!");
		return;
	}
	
	if (![audioSession setActive: YES error: &error])
	{
		NSLog(@"Error activating the audio session: %@", [error localizedDescription]);
		showAlert(@"Could not establish an Audio Connection. Sorry!");
		return;
	}
	
	[GKVoiceChatService defaultVoiceChatService].client = self;
	if (![[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID: peerID error: &error])
	{
		showAlert(@"Could not start voice chat. Sorry!");
		NSLog(@"Error starting voice chat: %@", [error userInfo]);
	}
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type 
{ 
    if (!self.session) { 
        self.session = [[GKSession alloc] initWithSessionID:(self.sessionID ? self.sessionID : @"Sample Session") displayName:nil sessionMode:GKSessionModePeer]; 
        self.session.delegate = self; 
    } 
	return session;
}

- (void) disconnect
{
	[self.session disconnectFromAllPeers];
	self.session = nil;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	
	if (state == GKPeerStateConnected)
	{
		self.isConnected = YES;
		showAlert(@"You are now connected for voice chat");
		if (self.viewController) 
			self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
	}
	
	if (state == GKPeerStateDisconnected)
	{
		self.isConnected = NO;
		showAlert(@"Lost connection with peer. You are no longer connected to another device.");
		[self disconnect];
		if (self.viewController) 
			self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(startConnection));
	}
}

- (void) assignViewController: (UIViewController *) aViewController
{
	self.viewController = aViewController;
	self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(startConnection));
}

/*
 CLASS-BASED INTERFACE UTILITIES
 */

+ (void) connect
{
	[[self sharedInstance] startConnection];
}

+ (void) disconnect
{
	[[self sharedInstance] disconnect];
}

+ (void) assignViewController: (UIViewController *) aViewController
{
	[[self sharedInstance] assignViewController:aViewController];
}
@end