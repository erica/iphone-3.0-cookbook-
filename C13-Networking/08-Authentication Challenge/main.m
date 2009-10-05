/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "DownloadHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
	IBOutlet UIProgressView *progress;
	NSString *savePath;
}
@property (retain) NSMutableString *log;
@property (retain) NSString *savePath;
@end

@implementation TestBedViewController
@synthesize log;
@synthesize savePath;

#define DEST_PATH	[NSHomeDirectory() stringByAppendingString:@"/Documents/"]

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	[textView setText:self.log];
}

- (void) restoreGUI
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Unauthorized", @selector(unauthorized:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Authorized", @selector(authorized:));
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[progress setHidden:YES];
}

- (void) dataDownloadAtPercent: (NSNumber *) aPercent
{
	[progress setHidden:NO];
	[progress setProgress:[aPercent floatValue]];
}

- (void) dataDownloadFailed: (NSString *) reason
{
	[self restoreGUI];
	if (reason) [self doLog:@"Download failed: %@", reason];
}

- (void) didReceiveFilename: (NSString *) aName
{
	self.savePath = [DEST_PATH stringByAppendingString:aName];
}

- (void) didReceiveData: (NSData *) theData
{
	NSString *results = [[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding] autorelease];
	[theData release];
	[self restoreGUI];
	[self doLog:results];
}

- (void) unauthorized: (UIBarButtonItem *) bbi
{
	self.log = [NSMutableString string];
	[self doLog:@"Starting Download..."];
	
	// Prepare for download
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	// Set up the Download Helper and start download
	NSString *urlString = @"http://ericasadun.com/Private/";
	[DownloadHelper sharedInstance].delegate = self;
	[DownloadHelper sharedInstance].username = nil;
	[DownloadHelper sharedInstance].password = nil;
	[DownloadHelper download:urlString];
}

- (void) authorized: (UIBarButtonItem *) bbi
{
	self.log = [NSMutableString string];
	[self doLog:@"Starting Download..."];
	
	// Prepare for download
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// Set up the Download Helper and start download
	NSString *urlString = @"http://ericasadun.com/Private/";
	[DownloadHelper sharedInstance].username = @"PrivateAccess";
	[DownloadHelper sharedInstance].password = @"tuR7!mZ#eh";
	[DownloadHelper sharedInstance].delegate = self;
	[DownloadHelper download:urlString];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Unauthorized", @selector(unauthorized:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Authorized", @selector(authorized:));
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
