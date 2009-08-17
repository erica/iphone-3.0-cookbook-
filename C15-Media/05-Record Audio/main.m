/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "ModalAlert.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define FILEPATH [DOCUMENTS_FOLDER stringByAppendingPathComponent:[self dateString]]

#define XMAX	20.0f

@interface TestBedViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
	AVAudioRecorder *recorder;
	AVAudioSession *session;
	IBOutlet UIProgressView *meter1;
	IBOutlet UIProgressView *meter2;
	NSTimer *timer;
}
@property (retain) AVAudioSession *session;
@property (retain) AVAudioRecorder *recorder;
@end

@implementation TestBedViewController
@synthesize session;
@synthesize recorder;

- (NSString *) dateString
{
	// return a formatted string for a file name
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"ddMMMYY_hhmmssa";
	return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".aif"];
}

- (NSString *) formatTime: (int) num
{
	// return a formatted ellapsed time string
	int secs = num % 60;
	int min = num / 60;
	if (num < 60) return [NSString stringWithFormat:@"0:%02d", num];
	return	[NSString stringWithFormat:@"%d:%02d", min, secs];
}

- (void) updateMeters
{
	// Show the current power levels
	[self.recorder updateMeters];
	float avg = [self.recorder averagePowerForChannel:0];
	float peak = [self.recorder peakPowerForChannel:0];
	meter1.progress = (XMAX + avg) / XMAX;
	meter2.progress = (XMAX + peak) / XMAX;

	// Update the current recording time
	self.title = [NSString stringWithFormat:@"%@", [self formatTime:self.recorder.currentTime]];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
	// Prepare UI for recording
	self.title = nil;
	meter1.hidden = NO;
	meter2.hidden = NO;
	{
		// Return to play and record session
		NSError *error;
		if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
		{
			NSLog(@"Error: %@", [error localizedDescription]);
			return;
		}
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(record));
	}

	// Delete the current recording
	[ModalAlert say:@"Deleting recording"];
	//[self.recorder deleteRecording]; <-- too flaky to use
	NSError *error;
	if (![[NSFileManager defaultManager] removeItemAtPath:[self.recorder.url path] error:&error])
		NSLog(@"Error: %@", [error localizedDescription]);

	// Release the player
	[player release];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
	// Stop monitoring levels, time
	[timer invalidate];
	meter1.progress = 0.0f;
	meter1.hidden = YES;
	meter2.progress = 0.0f;
	meter2.hidden = YES;
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	
	[ModalAlert say:@"File saved to %@", [[self.recorder.url path] lastPathComponent]];
	self.title = @"Playing back recording...";
	
	// Start playback
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
	player.delegate = self;
	
	// Change audio session for playback
	NSError *error;
	if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error])
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}

	[player play];
}

- (void) stopRecording
{
	// This causes the didFinishRecording delegate method to fire
	[self.recorder stop];
}

- (void) continueRecording
{
	// resume from a paused recording
	[self.recorder record];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(stopRecording));
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pauseRecording));
}

- (void) pauseRecording
{
	// pause an ongoing recording
	[self.recorder pause];
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Continue", @selector(continueRecording));
	self.navigationItem.rightBarButtonItem = nil;
}

- (BOOL) record
{
	NSError *error;
	
	// Recording settings
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings setValue: [NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
	[settings setValue: [NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
	[settings setValue: [NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey]; // mono
	[settings setValue: [NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[settings setValue: [NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
	
	// File URL
	NSURL *url = [NSURL fileURLWithPath:FILEPATH];
	
	// Create recorder
	self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
	if (!self.recorder)
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	
	// Initialize degate, metering, etc.
	self.recorder.delegate = self;
	self.recorder.meteringEnabled = YES;
	meter1.progress = 0.0f;
	meter2.progress = 0.0f;
	self.title = @"0:00";
	
	if (![self.recorder prepareToRecord])
	{
		NSLog(@"Error: Prepare to record failed");
		[ModalAlert say:@"Error while preparing recording"];
		return NO;
	}
	
	if (![self.recorder record])
	{
		NSLog(@"Error: Record failed");
		[ModalAlert say:@"Error while attempting to record audio"];
		return NO;
	}
	
	// Set a timer to monitor levels, current time
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateMeters) userInfo:nil repeats:YES];
	
	// Update the navigation bar
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(stopRecording));
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pauseRecording));

	return YES;
}

- (BOOL) startAudioSession
{
	// Prepare the audio session
	NSError *error;
	self.session = [AVAudioSession sharedInstance];
	
	if (![self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	
	if (![self.session setActive:YES error:&error])
	{
		NSLog(@"Error: %@", [error localizedDescription]);
		return NO;
	}
	
	return self.session.inputIsAvailable;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Audio Recorder";
	
	if ([self startAudioSession])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(record));
	else
		self.title = @"No Audio Input Available";
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
