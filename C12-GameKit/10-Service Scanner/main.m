/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#include <arpa/inet.h>
#include <netdb.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface ShowController : UIViewController
{
	NSString *text;
}
@property (retain) NSString *text;
- (id) initWithText: (NSString *) someText;
@end

@implementation ShowController
@synthesize text;

- (id) initWithText: (NSString *) someText
{
	if (self = [super init]) text = [someText retain];
	return self;
}

- (void) loadView
{
	self.title = @"Details";
	self.view = [[[UITextView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	UITextView *tv = (UITextView *) self.view;
	tv.editable = NO;
	tv.font = [UIFont fontWithName:@"Courier-Bold" size:14.0f];
	tv.text = self.text;
}

- (void) dealloc
{
	self.text = nil;
	[super dealloc];
}
@end



@interface TestBedViewController : UITableViewController
{
	NSMutableArray *results;
	NSMutableArray *services;
	NSNetServiceBrowser *browser;
}
@property (retain) NSMutableArray *results;
@property (retain) NSMutableArray *services;
@property (retain) NSNetServiceBrowser *browser;
@end

@implementation TestBedViewController
@synthesize results;
@synthesize services;
@synthesize browser;

- (NSString *) stringFromAddress: (const struct sockaddr *) address
{
	if(address && address->sa_family == AF_INET) {
		const struct sockaddr_in* sin = (struct sockaddr_in*) address;
		return [NSString stringWithFormat:@"%@:%d", [NSString stringWithUTF8String:inet_ntoa(sin->sin_addr)], ntohs(sin->sin_port)];
	}
	
	return nil;
}

- (NSMutableDictionary *) dictionaryMatchingType: (NSString *) type andName: (NSString *) name
{
	for (NSMutableDictionary *md in self.results)
	{
		if ([[md objectForKey:@"name"] isEqualToString:name] &&	[[md objectForKey:@"type"] isEqualToString:type])
			return md;
	}
	return nil;
}

- (NSMutableDictionary *) dictionaryForService: (NSNetService *) netService
{
	NSString *name = [netService name];
	NSString *type = [netService type];
	return [self dictionaryMatchingType:type andName:name];
}

- (void)netServiceDidResolveAddress:(NSNetService *)netService
{
	NSMutableDictionary *md = [self dictionaryForService:netService];
	if (!md) return;
	
	NSArray* addresses = [netService addresses];
	if ([addresses count] > 0)
	{
		NSMutableArray *naddresses = [NSMutableArray array];
		for (int i = 0; i < addresses.count; i++)
		{
			struct sockaddr* address = (struct sockaddr*)[[addresses objectAtIndex:i] bytes];
			NSString *addressString = [self stringFromAddress:address];
			if (!addressString) continue;
			[naddresses addObject:addressString];
		}
		
		[md setObject:naddresses forKey:@"addresses"];
	}
	
	[netService release];
}

- (void)netService:(NSNetService *)netService didUpdateTXTRecordData:(NSData *)data
{
	NSDictionary *dict = [NSNetService dictionaryFromTXTRecordData:data];
	NSMutableDictionary *md = [self dictionaryForService:netService];
	if (!md) return;
	if ([[dict allKeys] count] == 0) return;
	[md setObject:[dict description] forKey:@"other"];
}

- (void) netServiceBrowser:(NSNetServiceBrowser *) netServiceBrowser didFindService:(NSNetService *) netService 
				moreComing:(BOOL) moreServicesComing
{
	if (![netService hostName] && [[netService name] hasPrefix:@"_"])
		[self.services addObject:[netService name]];
	else
	{
		NSMutableDictionary *md = [NSMutableDictionary dictionary];
		[md setObject:[netService type] forKey:@"type"];
		[md setObject:[netService name] forKey:@"name"];
		[md setObject:[netService domain] forKey:@"domain"];
		[netService startMonitoring];
		[[netService retain] setDelegate:self];
		[netService resolveWithTimeout:0.0f];
		[self.results addObject:md];
		[self.tableView reloadData];
	}
	
	if (!moreServicesComing)
	{
		[self.browser stop];
		self.title = @"Services";
		
		if ([self.services count] > 0)
		{
			NSString *type = [self.services objectAtIndex:0];
			[self.services removeObject:type];
			type = [type stringByAppendingString:@"._tcp."];
			[self.browser searchForServicesOfType:type inDomain:@""];
		}
		else
			self.navigationItem.rightBarButtonItem = BARBUTTON(@"Rescan", @selector(scan:));
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo
{
	NSLog (@"Error: %@", errorInfo);
}

- (void) scan: (UIBarButtonItem *) bbi
{
	self.navigationItem.rightBarButtonItem = nil;
	self.title = @"Scanning...";
	self.services = [NSMutableArray array];
	self.results = [NSMutableArray array];
	self.browser = [[[NSNetServiceBrowser alloc] init] retain];
	[self.browser setDelegate:self];
	[self.browser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	NSDictionary *dict = [self.results objectAtIndex:indexPath.row];
	cell.textLabel.text = [dict objectForKey:@"type"];
	cell.detailTextLabel.text = [dict objectForKey:@"name"];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (NSString *) describeDict: (NSDictionary *) dict
{
	NSString *riz = [NSString stringWithFormat:@"Name:          %@\nType:          %@\nDomain:        %@\nAddresses:     %@\nOther Info:    %@\n",
					 [dict objectForKey:@"name"],
					 [dict objectForKey:@"type"],
					 [dict objectForKey:@"domain"],
					 [dict objectForKey:@"addresses"] ? [[dict objectForKey:@"addresses"] componentsJoinedByString:@", "] : @"[none]",
					 [dict objectForKey:@"other"] ? [dict objectForKey:@"other"] : @"[none]"
	];
	return riz;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSDictionary *dict = [self.results objectAtIndex:indexPath.row];
	NSString *description = [self describeDict:dict];
	if (!description) description = @"Error loading description.";
	[self.navigationController pushViewController:[[[ShowController alloc] initWithText:description] autorelease] animated:YES];
}

- (void) viewDidLoad
{
	self.title = @"Services";
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[self performSelector:@selector(scan:) withObject:nil afterDelay:0.5f];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
