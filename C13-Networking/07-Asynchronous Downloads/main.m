/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
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

#define SMALL_URL	@"http://www.archive.org/download/Drive-inSaveFreeTv/Drive-in--SaveFreeTv_512kb.mp4"
#define BIG_URL		@"http://www.archive.org/download/BettyBoopCartoons/Betty_Boop_More_Pep_1936_512kb.mp4"
#define FAKE_URL	@"http://www.idontbelievethisisavalidurlforthisexample.com"
#define DEST_PATH	[NSHomeDirectory() stringByAppendingString:@"/Documents/"]

-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie=[aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [theMovie release];
}

- (void) startPlayback : (id) sender
{
	MPMoviePlayerController* theMovie=[[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:self.savePath]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
	[theMovie play];
}

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
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Get Data", @selector(action:));
	if ([[NSFileManager defaultManager] fileExistsAtPath:DEST_PATH])
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Play", @selector(startPlayback:));	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[(UISegmentedControl *)self.navigationItem.titleView setEnabled:YES];
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
	if (![theData writeToFile:self.savePath atomically:YES])
		[self doLog:@"Error writing data to file"];

	[theData release];
	[self restoreGUI];
	[self doLog:@"Download succeeded"];
}

- (void) action: (UIBarButtonItem *) bbi
{
	self.log = [NSMutableString string];
	[self doLog:@"Starting Download..."];
	
	// Retrieve the URL string
	int which = [(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex];
	NSArray *urlArray = [NSArray arrayWithObjects: SMALL_URL, BIG_URL, FAKE_URL, nil];
	NSString *urlString = [urlArray objectAtIndex:which];

	// Prepare for download
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
	[(UISegmentedControl *)self.navigationItem.titleView setEnabled:NO];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

	// Set up the Download Helper and start download
	[DownloadHelper sharedInstance].delegate = self;
	[DownloadHelper download:urlString];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Get Data", @selector(action:));
	
	// Allow user to pick short or long data
	UISegmentedControl *seg = [[[UISegmentedControl alloc] initWithItems:[@"Short Long Wrong" componentsSeparatedByString:@" "]] autorelease];
	seg.selectedSegmentIndex = 0;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	self.navigationItem.titleView = seg;	
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
