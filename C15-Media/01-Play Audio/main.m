/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ModalMenu.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <AVAudioPlayerDelegate>
{
	AVAudioPlayer *player;
	NSTimer *timer;
	IBOutlet UIProgressView *meter1;
	IBOutlet UIProgressView *meter2;
	IBOutlet UISlider *scrubber;
	IBOutlet UISlider *volumeSlider;
	IBOutlet UILabel *nowPlaying;
	NSString *path;
}
@property (retain) AVAudioPlayer *player;
@property (retain) NSString *path;
@end

#define XMAX	30.0f

@implementation TestBedViewController
@synthesize player;
@synthesize path;

- (NSString *) formatTime: (int) num
{
	int secs = num % 60;
	int min = num / 60;
	
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (void) updateMeters
{
	[self.player updateMeters];
	float avg = -1.0f * [self.player averagePowerForChannel:0];
	float peak = -1.0f * [self.player peakPowerForChannel:0];
	meter1.progress = (XMAX - avg) / XMAX;
	meter2.progress = (XMAX - peak) / XMAX;
	
	self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:self.player.currentTime], [self formatTime:self.player.duration]];
	scrubber.value = (self.player.currentTime / self.player.duration);
}

- (void) pause: (id) sender
{
	if (self.player) [self.player pause];
	self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, self, @selector(play:));
	meter1.progress = 0.0f;
	meter2.progress = 0.0f;
	[timer invalidate];
	volumeSlider.enabled = NO;
	scrubber.enabled = NO;
}

- (void) play: (id) sender
{
	if (self.player) [self.player play];

	volumeSlider.value = self.player.volume;
	volumeSlider.enabled = YES;
	
	self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pause:));
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
	scrubber.enabled = YES;
}

- (void) setVolume: (id) sender
{
	if (self.player) self.player.volume = volumeSlider.value;
}

- (void) scrubbingDone: (id) sender
{
	[self play:nil];
}

- (void) scrub: (id) sender
{
	// Pause the player
	[self.player pause];
	
	// Calculate the new current time
	self.player.currentTime = scrubber.value * self.player.duration;
	
	// Update the title, nav bar
	self.title = [NSString stringWithFormat:@"%@ of %@", [self formatTime:self.player.currentTime], [self formatTime:self.player.duration]];
	self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, self, @selector(play:));
}

- (BOOL) prepAudio
{
	NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.path]) return NO;
	
	self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self.path] error:&error];
	if (!self.player)
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	
	[self.player prepareToPlay];
	self.player.meteringEnabled = YES;
	meter1.progress = 0.0f;
	meter2.progress = 0.0f;
	
	self.player.delegate = self;
	self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPlay, self, @selector(play:));
	scrubber.enabled = NO;
	
	return YES;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	self.navigationItem.rightBarButtonItem = nil;
	scrubber.value = 0.0f;
	scrubber.enabled = NO;
	volumeSlider.enabled = NO;
	[self prepAudio];
}

- (void) pick
{
	// Each of these media files is in the public domain via archive.org
	NSArray *choices = [@"Alexander's Ragtime Band*Hello My Baby*Ragtime Echoes*Rhapsody In Blue*A Tisket A Tasket*In the Mood*Cancel" componentsSeparatedByString:@"*"];
	NSArray *media = [@"ARB-AJ*HMB1936*ragtime*RhapsodyInBlue*Tisket*InTheMood" componentsSeparatedByString:@"*"];
	
	int answer = [ModalMenu menuWithTitle:@"Musical selections" view:self.view andButtons:choices];
	if (answer == (choices.count - 1)) return;
	
	self.path = [[NSBundle mainBundle] pathForResource:[media objectAtIndex:answer] ofType:@"mp3"];
	nowPlaying.text = [choices objectAtIndex:answer];
	[self.view viewWithTag:101].hidden = NO;
	[self.player stop];
	[self prepAudio];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Select Audio", @selector(pick));
	self.path= [[NSBundle mainBundle] pathForResource:@"ARB" ofType:@"mp3"];
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
