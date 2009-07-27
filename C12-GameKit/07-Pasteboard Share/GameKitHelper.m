
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "GameKitHelper.h"

@implementation GameKitHelper
@synthesize dataDelegate;
@synthesize viewController;
@synthesize sessionID;
@synthesize session;
@synthesize isConnected;

#define DO_DATA_CALLBACK(X, Y) if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(X)]) [self.dataDelegate performSelector:@selector(X) withObject:Y];
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

#pragma mark Shared Instance
static GameKitHelper *sharedInstance = nil;

+ (GameKitHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

#pragma mark Data Sharing
- (void) sendDataToPeers: (NSData *) data
{
	NSError *error;
	BOOL didSend = [self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
	if (!didSend)
		NSLog(@"Error sending data to peers: %@", [error localizedDescription]);
	DO_DATA_CALLBACK(sentData:, (didSend ? nil : [error localizedDescription]));
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	DO_DATA_CALLBACK(receivedData:, data);
}

#pragma mark Connections
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

// Dismiss the peer picker on cancel
- (void) peerPickerControllerDidCancel: (GKPeerPickerController *)picker
{
	[picker release];
	if (self.viewController) 
		self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(startConnection));
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session{ 
	[picker dismiss];
	[picker release];
	[self.session setDataReceiveHandler:self withContext:nil];
	isConnected = YES;
	DO_DATA_CALLBACK(connectionEstablished, nil);
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type 
{ 
	// The session ID is basically the name of the service, and is used to create the bonjour connection.
    if (!self.session) { 
        self.session = [[GKSession alloc] initWithSessionID:(self.sessionID ? self.sessionID : @"Sample Session") displayName:nil sessionMode:GKSessionModePeer]; 
        self.session.delegate = self; 
    } 
	return self.session;
}

#pragma mark Session Handling
- (void) disconnect
{
	[self.session disconnectFromAllPeers];
	self.session = nil;
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	/* STATES: GKPeerStateAvailable, = 0,  GKPeerStateUnavailable, = 1,  GKPeerStateConnected, = 2, 
	   GKPeerStateDisconnected, = 3, GKPeerStateConnecting = 4 */
	
	NSArray *states = [NSArray arrayWithObjects:@"Available", @"Unavailable", @"Connected", @"Disconnected", @"Connecting", nil];
	NSLog(@"Peer state is now %@", [states objectAtIndex:state]);
	
	 if (state == GKPeerStateConnected)
	 {
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
		 DO_DATA_CALLBACK(connectionLost, nil);
	 }
}

- (void) assignViewController: (UIViewController *) aViewController
{
	self.viewController = aViewController;
	self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(startConnection));
}

#pragma mark Class utility methods
+ (void) connect
{
	[[self sharedInstance] startConnection];
}

+ (void) disconnect
{
	[[self sharedInstance] disconnect];
}

+ (void) sendData: (NSData *) data
{
	[[self sharedInstance] sendDataToPeers:data];
}

+ (void) assignViewController: (UIViewController *) aViewController
{
	[[self sharedInstance] assignViewController:aViewController];
}

@end