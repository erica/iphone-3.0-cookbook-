/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "FTPHelper.h"

#define BASE_USERNAME @"ericasadun"
#define BASE_PASSWORD @"password"
#define BASE_URL @"ftp://Banana.local"
#define FILE_TO_MOVE @"foo.mp3"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <UITextFieldDelegate>
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@end

@implementation TestBedViewController
@synthesize log;

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	textView.text = self.log;
}

#pragma mark ***** TESTING LISTINGS
- (void) receivedListing: (NSArray *) listing
{
	textView.font = [UIFont fontWithName:@"Courier" size:10.0f];
	self.log = [NSMutableString string];

	[self doLog:@"FILE LISTING"];
	for (NSDictionary *dict in listing)
		[self doLog:[FTPHelper textForDirectoryListing:(CFDictionaryRef) dict]];
}

- (void) listingFailed
{
	textView.font = [UIFont systemFontOfSize:16.0f];
	self.log = [NSMutableString string];
	[self doLog:@"Listing failed."];
}

#pragma mark ***** TESTING UPLOAD
- (void) dataUploadFinished: (NSNumber *) bytes;
{
	textView.font = [UIFont systemFontOfSize:16.0f];
	self.log = [NSMutableString string];
	[self doLog:@"Upload Finished!"];
	[self doLog:@"Uploaded %@ bytes", bytes];
}

- (void) dataUploadFailed: (NSString *) reason
{
	textView.font = [UIFont systemFontOfSize:16.0f];
	self.log = [NSMutableString string];
	[self doLog:@"Upload Failed."];
}

#pragma mark ***** TESTING DOWNLOAD

- (void) downloadFinished
{
	textView.font = [UIFont systemFontOfSize:16.0f];
	self.log = [NSMutableString string];
	
	// There are probably better ways to get the file size
	NSData *data = [NSData dataWithContentsOfFile:[FTPHelper sharedInstance].filePath];
	[self doLog:@"Downloaded %d bytes\n", data.length];
	[self doLog:@"File stored to %@", [FTPHelper sharedInstance].filePath];
}

- (void) dataDownloadFailed: (NSString *) reason
{
	textView.font = [UIFont systemFontOfSize:16.0f];
	self.log = [NSMutableString string];
	[self doLog:@"Download failed..."];
	[self doLog:reason];
}

#pragma mark Missing Credentials
- (void) credentialsMissing
{
	self.log = [NSMutableString string];
	[self doLog:@"Please supply both user name and password before using FTP Helper"];
}

#pragma mark Testing
- (void) progressAtPercent: (NSNumber *) aPercent;
{
	// printf("%0.2f\n", aPercent.floatValue);
}

- (void) action: (id) sender
{
	[FTPHelper sharedInstance].delegate = self;
	[FTPHelper sharedInstance].uname = BASE_USERNAME;
	[FTPHelper sharedInstance].pword = BASE_PASSWORD;
	[FTPHelper sharedInstance].urlString = BASE_URL;

	// Listing
	[FTPHelper list:BASE_URL];
	
	// Download
	// [FTPHelper download: FILE_TO_MOVE];
	
	// Upload
	// [FTPHelper upload:FILE_TO_MOVE];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
