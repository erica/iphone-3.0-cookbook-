/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"
#import "ModalAlert.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <GameKitHelperDataDelegate>
@end

@implementation TestBedViewController

- (void) sharePasteboard
{
	// Construct a dictionary of the pasteboard type and data
	NSMutableDictionary *md = [NSMutableDictionary dictionary];
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	NSString *type = [[pb pasteboardTypes] lastObject];
	NSData *data = [pb dataForPasteboardType:type];
	[md setObject:type forKey:@"type"];
	[md setObject:data forKey:@"data"];
	
	// Deny any requests that are too big
	if (data.length > (95000))
	{
		[ModalAlert say:@"Too much data in pasteboard (%0.2f Kilobytes). GameKit can only send up to approx 90 Kilobytes at a time.", ((float) data.length) / 1000.0f];
		return;
	}
	
	// User must confirm share
	NSString *confirmString = [NSString stringWithFormat:@"Share %d bytes of type %@?", data.length, type];
	if (![ModalAlert ask:confirmString]) return;
	
	// Serialize and send the data
	NSString *errorString;
	NSData *plistdata = [NSPropertyListSerialization dataFromPropertyList:md format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorString];
	if (plistdata)
		[GameKitHelper sendData:plistdata];
	else
		CFShow(errorString);
}

- (void) sentData:(NSString *) errorString
{
	// dataDelegate callback checks to see if there was a problem sending data
	if (errorString)
	{
		[ModalAlert say:@"Error sending data: %@", errorString];
		return;
	}
	
	[ModalAlert say:@"Pasteboard data successfully queued for transmission."];
}

// On establishing the connection, allow the user to share the pasteboard
- (void) connectionEstablished
{
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	NSArray *types = [pb pasteboardTypes];
	if (types.count == 0) return;

	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Share Pasteboard", @selector(sharePasteboard));
}

// Hide the share option when the connection is lost
- (void) connectionLost
{
	self.navigationItem.leftBarButtonItem = nil;
}

-(void) receivedData: (NSData *) data
{
	// Deserialize the transmission
	CFStringRef errorString;
	NSDictionary *dict = (NSDictionary *)CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)data, kCFPropertyListMutableContainers, &errorString);
	if (!dict) 
	{
		CFShow(errorString);
		return;
	}
	
	// Retrieve the type and data
	NSString *type = [dict objectForKey:@"type"];
	NSData *sentdata = [dict objectForKey:@"data"];
	if (!type || !sentdata) return;
	
	// Do not copy to pasteboard unless the user permits
	NSString *message = [NSString stringWithFormat:@"Received %d bytes of type %@. Copy to pasteboard?", sentdata.length, type];
	if (![ModalAlert ask:message]) return;
	
	// Perform the pasteboard copy
	UIPasteboard *pb = [UIPasteboard generalPasteboard];
	if ([type isEqualToString:@"public.text"])
	{
		NSString *string = [[[NSString alloc] initWithData:sentdata encoding:NSUTF8StringEncoding] autorelease];
		[pb setString:string];
	}
	else [pb setData:sentdata forPasteboardType:type];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Pasteboard Share";
	[GameKitHelper sharedInstance].sessionID = @"Pasteboard Share";
	[GameKitHelper sharedInstance].dataDelegate = self;
	[GameKitHelper assignViewController:self];
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
