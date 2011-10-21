/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	AVAudioPlayer *player;
}
@property (retain) AVAudioPlayer *player;
@end

@implementation TestBedViewController
@synthesize player;

- (BOOL) prepAudio
{
	// Check for the file. "Drumskul" was released as a public domain audio loop on archive.org as part of "loops2try2".
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"loop" ofType:@"mp3"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;

	// Initialize the player
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	if (!self.player)
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}

	// Prepare the player and set the loops to, basically, unlimited
	[self.player prepareToPlay];
	[self.player setNumberOfLoops:999999];

	return YES;
}

- (void) viewDidAppear: (BOOL) animated
{
	// Start playing at no-volume
	self.player.volume = 0.0f;
	[self.player play];

	// fade in the audio over a second
	for (int i = 1; i <= 10; i++)
	{
		self.player.volume = i / 10.0f;
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
	}

	// Add the push button
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Push", @selector(push));
}

- (void) viewWillDisappear: (BOOL) animated
{
	// fade out the audio over a second
	for (int i = 9; i >= 0; i--)
	{
		self.player.volume = i / 10.0f;
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1f]];
	}

	[self.player pause];
}

- (void) push
{
	// Create a simple new view controller
	UIViewController *vc = [[UIViewController alloc] init];
	vc.view.backgroundColor = [UIColor whiteColor];
	vc.title = @"No Sounds";

	// Disable the now-pressed right-button
	self.navigationItem.rightBarButtonItem = nil;

	// push the new view controller
	[self.navigationController pushViewController:[vc autorelease] animated:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Push", @selector(push));
	self.title = @"Looped Sounds";
	[self prepAudio];
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
