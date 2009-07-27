/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "BonjourHelper.h"
#import "ModalAlert.h"
#import "ModalHUD.h"
#import "NetReachability.h"
#include <unistd.h>
#include <sys/sysctl.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netinet/in.h>
#include <ifaddrs.h>

#define DO_DATA_CALLBACK(X, Y) if (sharedInstance.dataDelegate && [sharedInstance.dataDelegate respondsToSelector:@selector(X)]) [sharedInstance.dataDelegate performSelector:@selector(X) withObject:Y];
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:[BonjourHelper class] action:SELECTOR] autorelease]

@implementation BonjourHelper
@synthesize server;
@synthesize service;
@synthesize browser;
@synthesize inConnection;
@synthesize outConnection;

@synthesize dataDelegate;
@synthesize viewController;
@synthesize sessionID;

@synthesize isConnected;

static BonjourHelper *sharedInstance = nil;

BOOL inConnected;
BOOL outConnected;

+ (BonjourHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

#pragma mark Utilities
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
	char baseHostName[255];
	int success = gethostname(baseHostName, 255);
	if (success != 0) return nil;
	baseHostName[255] = '\0';
#if TARGET_IPHONE_SIMULATOR
	return [NSString stringWithCString:baseHostName];
#else
	return [[NSString stringWithCString:baseHostName] stringByAppendingString:@".local"];
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
		return [NSString stringWithCString:inet_ntoa(*list[0])];
    }
	return nil;
}

#pragma mark Connection Status
- (void) updateConnectionStatus
{
	if (!(self.inConnection && self.outConnection))
	{
		printf("in connection: %s\n", self.inConnection ? "yes" : "no");
		printf("out connection: %s\n", self.outConnection ? "yes" : "no");
		self.isConnected = NO;
		return;
	}
	
	if (!(inConnected && outConnected))
	{
		printf("Connections not yet established. In: %d, Out: %d\n", inConnected, outConnected);
		self.isConnected = NO;
		return;
	}
	
	self.isConnected = YES;
	DO_DATA_CALLBACK(connectionEstablished, nil);
	[ModalHUD dismiss];
	if (self.viewController)
		self.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Disconnect", @selector(disconnect));
}


#pragma mark Client

// Perform a blocking receive only when data is available
- (void) checkForData
{
	if ([self.outConnection hasDataAvailable]) [self.outConnection receiveData];
	[self performSelector:@selector(checkForData) withObject:self afterDelay:0.1f];
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
			[self.browser release];
			self.browser = nil;
			
			// Create an outbound connection to this new service
			self.outConnection = [[[TCPConnection alloc] initWithRemoteAddress:address] autorelease];
			[self.outConnection setDelegate:self];
			[self checkForData];

			[self updateConnectionStatus];
			return;
		}
	} 
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing
{
	self.service = netService;
	[service setDelegate:self];
	[service resolveWithTimeout:0.0f];
}

+ (void) startBrowsingForServices
{
	sharedInstance.browser = [[NSNetServiceBrowser alloc] init];
	[sharedInstance.browser setDelegate:sharedInstance];
	NSString *type = [TCPConnection bonjourTypeFromIdentifier:sharedInstance.sessionID];
	[sharedInstance.browser searchForServicesOfType:type inDomain:@"local"];
}

#pragma mark Host
/*
 - (void) serverDidStart:(TCPServer*)server;
 - (void) serverDidEnableBonjour:(TCPServer*)server withName:(NSString*)name;
 - (void) server:(TCPServer*)server didNotEnableBonjour:(NSDictionary *)errorDict;
 - (BOOL) server:(TCPServer*)server shouldAcceptConnectionFromAddress:(const struct sockaddr*)address;
 - (void) server:(TCPServer*)server didOpenConnection:(TCPServerConnection*)connection; 
 - (void) server:(TCPServer*)server didCloseConnection:(TCPServerConnection*)connection;
 - (void) serverWillDisableBonjour:(TCPServer*)server;
 - (void) serverWillStop:(TCPServer*)server;
 */

+ (void) publish
{
	// Publish
	sharedInstance.server = [[[TCPServer alloc] initWithPort:0] autorelease];
	[sharedInstance.server setDelegate:sharedInstance];
	[sharedInstance.server startUsingRunLoop:[NSRunLoop currentRunLoop]];
	[sharedInstance.server enableBonjourWithDomain:@"local" applicationProtocol:sharedInstance.sessionID name:[self localHostname]];
}

#pragma mark GUI
+ (void) assignViewController: (UIViewController *) aViewController
{
	sharedInstance.viewController = aViewController;
	if (sharedInstance.viewController)
		sharedInstance.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
}

+ (void) initConnections
{
	sharedInstance.inConnection = nil;
	sharedInstance.outConnection = nil;
	sharedInstance.isConnected = NO;
	inConnected = NO;
	outConnected = NO;
}

+ (void) connect
{
	if (sharedInstance.viewController)
		sharedInstance.viewController.navigationItem.rightBarButtonItem = nil;
	if (!sharedInstance.sessionID) sharedInstance.sessionID = @"Sample Session";
	
	[ModalHUD showHUD:@"Searching for connection peer on your local network"];
	
	// Prepare for duplex connection
	[self initConnections];
	[self startBrowsingForServices];
	[self publish];
}

+ (void) disconnect
{
	// disable current connections
	[sharedInstance.inConnection invalidate];
	[sharedInstance.outConnection invalidate];
	[self initConnections];
	
	// stop server
	[sharedInstance.server stop];
	[sharedInstance updateConnectionStatus];
	
	// reset 
	[ModalHUD dismiss];
	if (sharedInstance.viewController)
		sharedInstance.viewController.navigationItem.rightBarButtonItem = BARBUTTON(@"Connect", @selector(connect));
}

#pragma mark  Client
+ (void) sendData: (NSData *) data
{
	if (!sharedInstance.outConnection) return;
	BOOL success = [sharedInstance.outConnection sendData:data];
	if (success) {
		DO_DATA_CALLBACK(sentData:, nil); }
	else {
		DO_DATA_CALLBACK(sentData:, @"Data could not be sent.");}
}

#pragma mark Connections
/*
 - (void) connectionDidFailOpening:(TCPConnection*)connection;
 - (void) connectionDidOpen:(TCPConnection*)connection;
 - (void) connectionDidClose:(TCPConnection*)connection;
 - (void) connection:(TCPConnection*)connection didReceiveData:(NSData*)data;
*/

- (BOOL) server:(TCPServer*)server shouldAcceptConnectionFromAddress:(const struct sockaddr*)address
{
	return !self.isConnected;
}

- (void) connectionDidFailOpening:(TCPConnection*)connection
{
	if (!connection) return;
	if ((connection != self.inConnection) && (connection != self.outConnection)) return;
	
	[BonjourHelper disconnect];
	[ModalAlert say:@"Error while opening %@ connection. Wait a few seconds (or relaunch) before trying to connect again.", (connection == self.inConnection) ? @"incoming" : @"outgoing"];
}

- (void) server:(TCPServer*)server didCloseConnection:(TCPServerConnection*)connection
{
	[BonjourHelper disconnect];
	[ModalAlert say:@"Lost connection with peer. You are no longer connected to another device."];
}

- (void) server:(TCPServer*)server didOpenConnection:(TCPServerConnection*)connection
{
	self.inConnection = connection;
	[self updateConnectionStatus];
	[connection setDelegate:self];
}

- (void) connectionDidOpen: (TCPConnection *) connection
{
	printf("Connection did open: %s\n", (connection == self.inConnection) ? "incoming" : "outgoing");
	if (connection == self.inConnection) inConnected = YES;
	if (connection == self.outConnection) outConnected = YES;
	[self updateConnectionStatus];
}

- (void) connectionDidClose: (TCPConnection *)connection
{
	printf("Connection did close: %s\n", (connection == self.inConnection) ? "incoming" : "outgoing");
	if (connection == self.inConnection) inConnected = NO;
	if (connection == self.outConnection) outConnected = NO;
}

- (void) connection:(TCPConnection*)connection didReceiveData:(NSData*)data;
{
	DO_DATA_CALLBACK(receivedData:, data);
}
@end
