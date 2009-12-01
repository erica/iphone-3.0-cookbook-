
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "GameKitHelper.h"

#define TIME_OUT_TIME	60.0f

/*

 Peer Tracker helps ignored already-identified peers, skipping them while trying to
 establish a connection. Apple's Peer Picker doesn't do this, hence the ghost
 connections that appear on the gk stack.
 
 */
@interface PeerTracker : NSObject
+ (BOOL) vetPeerID: (NSString *) anID;
@end

@implementation PeerTracker
+ (BOOL) vetPeerID: (NSString *) anID
{
	NSDictionary *storedPeers = [[NSUserDefaults standardUserDefaults] objectForKey:@"Peer Dictionary"];
	NSMutableDictionary *knownPeers = storedPeers ? [NSMutableDictionary dictionaryWithDictionary:storedPeers] : [NSMutableDictionary dictionary];
	
	// Is the peer found? Will vet if not found
	BOOL result = [knownPeers objectForKey:anID] != nil;
	
	// Clean up the dictionary
	for (NSString *key in [knownPeers allKeys])
	{
		NSDate *date = [knownPeers objectForKey:key];
		if (ABS([[NSDate date] timeIntervalSinceDate:date]) > 60 * 60) // over 1 hour
			[knownPeers removeObjectForKey:key];
	}
	
	// Register the peer
	[knownPeers setObject:[NSDate date] forKey:anID];
	
	[[NSUserDefaults standardUserDefaults] setObject:knownPeers forKey:@"Peer Dictionary"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return result;
}
@end

@implementation GameKitHelper
@synthesize sessionID;
@synthesize mySession;
@synthesize viewController;

#define DO_DATA_CALLBACK(X, Y) if (viewController && [viewController respondsToSelector:@selector(X)]) [viewController performSelector:@selector(X) withObject:Y];
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

- (BOOL) isConnected
{
	return (connectStage == 2);
}

- (void) disconnect
{
	// Manually disconnect from all current peers
	[mySession disconnectFromAllPeers];
	[mySession setAvailable:NO];
	connectStage = 0;
	self.mySession = nil;
	
	// Update the GUI
	viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
}

- (void) connect
{
	if (mySession) return; // already trying to connect
	
	// Update the GUI
	viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Cancel...", @selector(disconnect));

	NSLog(@"Starting up...");
	if (!self.sessionID) self.sessionID = @"Sample Session";
	self.mySession = [[GKSession alloc] initWithSessionID:self.sessionID displayName:nil sessionMode:GKSessionModePeer];

	// Allow session to become available 
	[mySession release];
	mySession.delegate = self;
	[mySession setAvailable:YES];
	connectStage = 0;	
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
	NSLog(@"End of the world as we know it...");
	NSLog(@"Session failed with error: %@", [error localizedDescription]);
	[self disconnect];
}

- (void) connectAgain: (NSString *) peerID
{
	// Don't connect again if we're already connected,  otherwise try again
	if (connectStage == 2) return;
	[mySession connectToPeer:peerID withTimeout:TIME_OUT_TIME];
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
	// Don't connect again if we're already connected,  otherwise try again
	if (connectStage == 2) return;
	NSLog(@"Connection failed with peer %@ with error: %@", [session displayNameForPeer:peerID], [error localizedDescription]);
	[session setAvailable:YES];
	[self performSelector:@selector(connectAgain:) withObject:peerID afterDelay:2.0f];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
	// Peer is trying to connect. Accept that connection.
	NSLog(@"Received connection request from peer %@\n", [session displayNameForPeer:peerID]);
	NSLog(@"Attempting to connect...");
	
	NSError *error;
	BOOL yorn = [session acceptConnectionFromPeer:peerID error:&error];
	if (!yorn)
		NSLog(@"Attempt %d: Error accepting connection from %@: %@", [session displayNameForPeer:peerID], [error localizedDescription]);
	else 
	{
		NSLog(@"Accepted connection from %@", [session displayNameForPeer:peerID]);
		[mySession setDataReceiveHandler:self withContext:nil];
		connectStage = 2;
		DO_DATA_CALLBACK(connectionEstablished, nil);
				
		if (session != mySession) self.mySession = session;
		
		// Update the GUI
		viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
	}
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
	switch (state)
	{
		case GKPeerStateAvailable: 
		{
			if ([PeerTracker vetPeerID:peerID])
			{
				NSLog(@"Recognized available peer (%@). Ignoring it.", [session displayNameForPeer:peerID]);
				return;
			}
			
			if (connectStage == 0)
			{
				NSLog(@"Peer %@ is available. Attempting to connect.", [session displayNameForPeer:peerID]);
				connectStage = 1;
				[session connectToPeer:peerID withTimeout:TIME_OUT_TIME];
			}
			break;
		}
		case GKPeerStateUnavailable:
			NSLog(@"Peer %@ is no longer available", [session displayNameForPeer:peerID]);
			break;
		case GKPeerStateConnected:
		{
			NSLog(@"Peer %@ has connected", [session displayNameForPeer:peerID]);
			if (session != mySession)
				self.mySession = session;
			
			[mySession setDataReceiveHandler:self withContext:nil];
			connectStage = 2;
			DO_DATA_CALLBACK(connectionEstablished, nil);

			// Update the GUI
			viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
			break;
		}
		case GKPeerStateDisconnected:
		{
			DO_DATA_CALLBACK(connectionLost, nil);
			NSLog(@"Peer %@ is disconnected", [session displayNameForPeer:peerID]);
			
			if (connectStage == 2)
			{
				// Update the GUI
				viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
				connectStage = 0;
			}

			break;
		}
		case GKPeerStateConnecting:
			NSLog(@"Peer %@ is connecting...", [session displayNameForPeer:peerID]);
			connectStage = 1;
			break;
		default:
			break;
	}
}

#pragma mark Data Sharing
- (void) sendData: (NSData *) data
{
	NSError *error;
	BOOL didSend = [mySession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error];
	if (!didSend)
		NSLog(@"Error sending data to peers: %@", [error localizedDescription]);
	DO_DATA_CALLBACK(sentData:, (didSend ? nil : [error localizedDescription]));
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	DO_DATA_CALLBACK(receivedData:, data);
}
@end