/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate>
{
	AVAudioPlayer *player;
}
@property (retain) AVAudioPlayer *player;
@end

@implementation TestBedViewController
@synthesize player;

void interruptionListenerCallback (void    *userData, UInt32  interruptionState)
{
	// TestBedViewController *tbvc = (TestBedViewController *) userData;
	if (interruptionState == kAudioSessionBeginInterruption)
	{
		printf("(ilc) Interruption Detected\n");
	}
	else if (interruptionState == kAudioSessionEndInterruption)
	{
		printf("(ilc) Interruption ended\n");
	}
}

- (BOOL) prepAudio
{
	NSError *error;
	NSString *path = [[NSBundle mainBundle] pathForResource:@"MeetMeInSt.Louis1904" ofType:@"mp3"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return NO;
	
	// Catch interruptions via callback
	AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, self);
	AudioSessionSetActive(true);
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty( kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	
	/* Audio ends up too low!
	if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	 */
	
	// Initialize the player
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
	self.player.volume = 1.0f;
	self.player.delegate = self; 
	if (!self.player)
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	
	[self.player prepareToPlay];

	return YES;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	// just keep playing
	[self.player play];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
	// perform any interruption handling here
	printf("(apbi) Interruption Detected\n");
	[[NSUserDefaults standardUserDefaults] setFloat:[self.player currentTime] forKey:@"Interruption"];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
	// resume playback at the end of the interruption
	printf("(apei) Interruption ended\n");
	[self.player play];
	
	// remove the interruption key. it won't be needed
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[self prepAudio];

	// Check for previous interruption
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Interruption"])
	{
		self.player.currentTime = [[NSUserDefaults standardUserDefaults] floatForKey:@"Interruption"];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Interruption"];
	}
	
	// Start playback
	[self.player play];
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
