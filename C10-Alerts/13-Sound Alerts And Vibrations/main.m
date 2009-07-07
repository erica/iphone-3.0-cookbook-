/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	SystemSoundID mysound;
}
@end

@implementation TestBedViewController
- (void) playSound
{
	if ([MPMusicPlayerController iPodMusicPlayer].playbackState ==  MPMusicPlaybackStatePlaying)
		AudioServicesPlayAlertSound(mysound);
	else
		AudioServicesPlaySystemSound(mysound);
}

- (void) vibrate
{
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;

	// create the sound
	NSString *sndpath = [[NSBundle mainBundle] pathForResource:@"basicsound" ofType:@"wav"];
	CFURLRef baseURL = (CFURLRef)[NSURL fileURLWithPath:sndpath];
	
	// Identify it as not a UI Sound
    AudioServicesCreateSystemSoundID(baseURL, &mysound);
	AudioServicesPropertyID flag = 0;  // 0 means always play
	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), &mysound, sizeof(AudioServicesPropertyID), &flag);
	
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Sound", @selector(playSound));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Vibrate", @selector(vibrate));
}

-(void) dealloc
{
    if (mysound) AudioServicesDisposeSystemSoundID(mysound);
    [super dealloc];
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
