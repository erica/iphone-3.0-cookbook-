/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "BonjourHelper.h"
#import "ModalAlert.h"
#import "NetReachability.h"
#include <arpa/inet.h>
#include <netdb.h>

#define DO_DATA_CALLBACK(X, Y) if (sharedInstance.dataDelegate && [sharedInstance.dataDelegate respondsToSelector:@selector(X)]) [sharedInstance.dataDelegate performSelector:@selector(X) withObject:Y];
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:[BonjourHelper class] action:SELECTOR] autorelease]

@implementation BonjourHelper
@synthesize server;
@synthesize browser;
@synthesize inConnection;
@synthesize outConnection;

@synthesize dataDelegate;
@synthesize viewController;
@synthesize sessionID;

@synthesize isConnected;

@synthesize hud;

static BonjourHelper *sharedInstance = nil;

BOOL inConnected;
BOOL outConnected;

+ (BonjourHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

#pragma mark Network Utilities
+ (BOOL) performWiFiCheck
{
	NetReachability *nr = [[[NetReachability alloc] initWithDefaultRoute:YES] autorelease];
	if (![nr isReachable] || ([nr isReachable] && [nr isUsingCell]))
	{
		[ModalAlert performSelector:@selector(say:) withObject:@"This application requires WiFi. Please enable WiFi in Settings and run this application again." afterDelay:0.5f];
		return NO;
	}
	return YES;
}

// Direct from Apple. Thank you Apple
+ (BOOL)addressFromString:(NSString *)IPAddress address:(struct sockaddr_in *)address
{
	if (!IPAddress || ![IPAddress length]) {
		return NO;
	}
	
	memset((char *) address, sizeof(struct sockaddr_in), 0);
	address->sin_family = AF_INET;
	address->sin_len = sizeof(struct sockaddr_in);
	
	int conversionResult = inet_aton([IPAddress UTF8String], &address->sin_addr);
	if (conversionResult == 0) {
		NSAssert1(conversionResult != 1, @"Failed to convert the IP address string into a sockaddr_in: %@", IPAddress);
		return NO;
	}
	
	return YES;
}

+ (NSString *) stringFromAddress: (const struct sockaddr *) address
{
	if(address && address->sa_family == AF_INET) {
		const struct sockaddr_in* sin = (struct sockaddr_in*) address;
		return [NSString stringWithFormat:@"%@:%d", [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)], ntohs(sin->sin_port)];
	}
	
	return nil;
}

+ (NSString *) localHostname
{
	char baseHostName[256]; // Thanks, Gunnar Larisch
	int success = gethostname(baseHostName, 255);
	if (success != 0) return nil;
	baseHostName[255] = '\0';
#if TARGET_IPHONE_SIMULATOR
	return [NSString stringWithCString:baseHostName encoding: NSUTF8StringEncoding];
#else 
	return [[NSString stringWithCString:baseHostName encoding: NSUTF8StringEncoding] stringByAppendingString:@".local"];
#endif
}

+ (NSString *) localIPAddress
{
	struct hostent *host = gethostbyname([[self localHostname] UTF8String]);
    if (host == NULL)
	{
        herror("resolv");
		return nil;
	}
    else {
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
		return [NSString stringWithCString:inet_ntoa(*list[0]) encoding:NSUTF8StringEncoding];
    }
	return nil;
}

#pragma mark Class utilities
+ (void) assignViewController: (UIViewController *) aViewController
{
	sharedInstance.viewController = aViewController;
	if (sharedInstance.viewController)
		sharedInstance.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
}

#pragma mark Handshaking

- (void) updateStatus
{
	printf("Base:  Incoming: %s, Outgoing: %s\n", inConnection ? "connected" : "not connected", outConnection ? "connected" : "not connected");
	printf("Final: Incoming: %s, Outgoing: %s\n", inConnected ? "connected" : "not connected", outConnected ? "connected" : "not connected");

	// Must be connected to continue
	if (!(self.inConnection && self.outConnection) ||
		!(inConnected && outConnected))
	{
		self.isConnected = NO;
		return;
	}
	
	// Send callback, dismiss HUD, update bar button
	self.isConnected = YES;
	DO_DATA_CALLBACK(connectionEstablished, nil);
	[self.hud dismissWithClickedButtonIndex:1 animated:YES];
	if (self.viewController)
		self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
}

// Upon resolving address, create a connection to that address and request data
- (void)netServiceDidResolveAddress:(NSNetService *)netService
{
	NSArray* addresses = [netService addresses];
	if (addresses && addresses.count)
	{
		for (int i = 0; i < addresses.count; i++)
		{
			struct sockaddr* address = (struct sockaddr*)[[addresses objectAtIndex:i] bytes];
			NSString *addressString = [BonjourHelper stringFromAddress:address];
			if (!addressString) continue;
			
			if ([addressString hasPrefix:[BonjourHelper localIPAddress]])
			{
				printf("Will not resolve with self. Continuing to browse.\n");
				continue;
			}
			
			printf("Found a matching external service\n");
			printf("My address: %s\n", [[BonjourHelper localIPAddress] UTF8String]);
			printf("Remote address: %s\n", [addressString UTF8String]);

			// Stop browsing for services
			[self.browser stop];
			[netService release];
			
			// Create an outbound connection to this new service
			self.outConnection = [[[TCPConnection alloc] initWithRemoteAddress:address] autorelease];
			[self.outConnection setDelegate:self];
			[self performSelector:@selector(checkForData)];

			[self updateStatus];
			return;
		}
	} 
	[netService release];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
	[[netService retain] setDelegate:self];
	[netService resolveWithTimeout:0.0f];
}

+ (void) startBrowsingForServices
{
	sharedInstance.browser = [[[NSNetServiceBrowser alloc] init] retain];
	[sharedInstance.browser setDelegate:sharedInstance];
	NSString *type = [TCPConnection bonjourTypeFromIdentifier:sharedInstance.sessionID];
	[sharedInstance.browser searchForServicesOfType:type inDomain:@"local"];
}

- (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)name
{
	printf("Bonjour established\n");
}

- (void) server:(TCPServer*)server didNotEnableBonjour:(NSDictionary *)errorDict
{
	printf("Error establishing bonjour\n");
	CFShow(errorDict);
}

+ (void) publish
{
	sharedInstance.server = [[[TCPServer alloc] initWithPort:0] autorelease];
	[sharedInstance.server setDelegate:sharedInstance];
	[sharedInstance.server startUsingRunLoop:[NSRunLoop currentRunLoop]];
	[sharedInstance.server enableBonjourWithDomain:nil applicationProtocol:sharedInstance.sessionID name:[BonjourHelper localHostname]];
}

+ (void) initConnections
{
	[sharedInstance.browser stop];
	[sharedInstance.server stop];
	
	sharedInstance.inConnection = nil;
	sharedInstance.outConnection = nil;
	sharedInstance.isConnected = NO;
	inConnected = NO;
	outConnected = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex) return; // for non-Cancel
	[BonjourHelper disconnect];
}

+ (void) connect
{
	if (sharedInstance.viewController)
		sharedInstance.viewController.navigationItem.rightBarButtonItem = nil;
	if (!sharedInstance.sessionID) sharedInstance.sessionID = @"Sample Session";
	
	// Prepare for duplex connection
	[self initConnections];
	[self startBrowsingForServices];
	[self publish];

	// Show HUD
	sharedInstance.hud = [[[UIAlertView alloc] initWithTitle:@"Searching for connection peer on your local network" message:@"\n\n" delegate:sharedInstance cancelButtonTitle:@"Cancel" otherButtonTitles:nil] autorelease];
	[sharedInstance.hud show];
	UIActivityIndicatorView *aiv = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
	[aiv startAnimating];
	aiv.center = CGPointMake(sharedInstance.hud.bounds.size.width / 2.0f, sharedInstance.hud.bounds.size.height/2.0f);
	[sharedInstance.hud addSubview:aiv];
}

+ (void) disconnect
{
	// disable current connections
	[sharedInstance.inConnection invalidate];
	[sharedInstance.outConnection invalidate];
	[self initConnections];
	
	// stop server
	[sharedInstance.server stop];
	[sharedInstance updateStatus];
	
	// reset 
	[sharedInstance.hud dismissWithClickedButtonIndex:1 animated:YES];
	if (sharedInstance.viewController)
		sharedInstance.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
}

#pragma mark  Data Handling
- (void) checkForData
{
	// Perform a blocking receive only when data is available
	if (!self.outConnection) return;
	if ([self.outConnection hasDataAvailable]) [self.outConnection receiveData];
	[self performSelector:@selector(checkForData) withObject:self afterDelay:0.1f];
}

+ (void) sendData: (NSData *) data
{
	if (!sharedInstance.outConnection) return;
	BOOL success = [sharedInstance.outConnection sendData:data];
	if (success) {
		DO_DATA_CALLBACK(sentData:, nil); }
	else {
		DO_DATA_CALLBACK(sentData:, @"Data could not be sent.");}
}

- (void) connection:(TCPConnection*)connection didReceiveData:(NSData*)data;
{
	// Redirect data callback
	DO_DATA_CALLBACK(receivedData:, data);
}

#pragma mark Connection Handlers

- (BOOL) server:(TCPServer*)server shouldAcceptConnectionFromAddress:(const struct sockaddr*)address
{
	// Accept connections only while not connected
	return !self.isConnected;
}

- (void) connectionDidFailOpening:(TCPConnection*)connection
{
	// Handled a fail open
	if (!connection) return;
	NSString *addressString = [BonjourHelper stringFromAddress:connection.remoteSocketAddress];
	[BonjourHelper disconnect];

	if (addressString) 
		[ModalAlert say:@"Error while opening %@ connection (from %@). Wait a few seconds or relaunch before trying to connect again.", (connection == self.inConnection) ? @"incoming" : @"outgoing", addressString];
	else
		printf("Failed to open connection from unknown address\n");
}

- (void) server:(TCPServer*)server didCloseConnection:(TCPServerConnection*)connection
{
	// Handle a closed connection
	if (!connection) return;
	NSString *addressString = [BonjourHelper stringFromAddress:connection.remoteSocketAddress];
	if (!addressString) return;
	
	BOOL wasConnected = self.isConnected;
	
	[BonjourHelper disconnect];
	printf("Lost connection from %s\n", [addressString UTF8String]);
	
	if (wasConnected)
		[ModalAlert say:@"Disconnected from peer (%@). You are no longer connected to another device.", addressString];
	else
		[ModalAlert say:@"Peer was lost before full connection could be established."];
}

- (void) server:(TCPServer*)server didOpenConnection:(TCPServerConnection*)connection
{
	// Set the connection but wait for it to fully open
	self.inConnection = connection;
	[self updateStatus];
	[connection setDelegate:self];
}

- (void) connectionDidOpen: (TCPConnection *) connection
{
	// Fully opened connection
	printf("Connection did open: %s\n", (connection == self.inConnection) ? "incoming" : "outgoing");
	if (connection == self.inConnection) inConnected = YES;
	if (connection == self.outConnection) outConnected = YES;
	[self updateStatus];
}

- (void) connectionDidClose: (TCPConnection *)connection
{
	// Closed connection
	printf("Connection did close: %s\n", (connection == self.inConnection) ? "incoming" : "outgoing");
	if (connection == self.inConnection) inConnected = NO;
	if (connection == self.outConnection) outConnected = NO;
}
@end
