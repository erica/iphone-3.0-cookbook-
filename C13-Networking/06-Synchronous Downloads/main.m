/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
	NSString *savePath;
}
@property (retain) NSMutableString *log;
@property (retain) NSString *savePath;
@end

@implementation TestBedViewController
@synthesize log;
@synthesize savePath;

// relatively short movie (3 MB)
#define SMALL_URL	@"http://www.archive.org/download/Drive-inSaveFreeTv/Drive-in--SaveFreeTv_512kb.mp4"

// bigger movie (23 MB)
#define BIG_URL	@"http://www.archive.org/download/BettyBoopCartoons/Betty_Boop_More_Pep_1936_512kb.mp4"

// Wrong URL
#define FAKE_URL @"http://www.idontbelievethisisavalidurlforthisexample.com"

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
	[textView performSelectorOnMainThread:@selector(setText:) withObject:self.log waitUntilDone:NO];
}

- (void) finishedGettingData
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Get Data", @selector(action:));
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.savePath])
		self.navigationItem.leftBarButtonItem = BARBUTTON(@"Play", @selector(startPlayback:));	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[(UISegmentedControl *)self.navigationItem.titleView setEnabled:YES];
}

- (void) getData: (NSNumber *) which
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	self.log = [NSMutableString string];
	[self doLog:@"Downloading data now...\n"];
	NSDate *date = [NSDate date];
	
	NSArray *urlArray = [NSArray arrayWithObjects: SMALL_URL, BIG_URL, FAKE_URL, nil];
	NSURL *url = [NSURL URLWithString: [urlArray objectAtIndex:[which intValue]]];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	NSURLResponse *response;
	NSError *error;
	NSData* result = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&error];
	[self doLog:@"Response expects %d bytes", [response expectedContentLength]];
	[self doLog:@"Response suggested file name: %@", [response suggestedFilename]];
	if ([response suggestedFilename])
		self.savePath = [DEST_PATH stringByAppendingString:[response suggestedFilename]];
	
	if (!result)
		[self doLog:@"Error downloading data: %@.", [error localizedDescription]];
	else if ([response expectedContentLength] < 0)
		[self doLog:@"Error with download. Carrier redirect?"];
	else
	{
		[self doLog:@"Download succeeded."];
		[self doLog:@"Read %d bytes", result.length];
		[self doLog:@"Elapsed time: %0.2f seconds.", -1*[date timeIntervalSinceNow]];
		[result writeToFile:self.savePath atomically:YES];
		[self doLog:@"Data written to file: %@.", self.savePath];
	}
	
	[self performSelectorOnMainThread:@selector(finishedGettingData) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void) action: (UIBarButtonItem *) bbi
{
	NSNumber *which = [NSNumber numberWithInt:[(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]];
	self.navigationItem.rightBarButtonItem = nil;
	[(UISegmentedControl *)self.navigationItem.titleView setEnabled:NO];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[NSThread detachNewThreadSelector:@selector(getData:) toTarget:self withObject:which];
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
