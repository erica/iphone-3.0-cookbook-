/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AccelerometerHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <AccelerometerHelperDelegate>
{
	IBOutlet UITextField *sensitivity;
	IBOutlet UITextField *timelock;
	IBOutlet UILabel *acceleration;
	IBOutlet UITextView *feedback;
	
	SystemSoundID sound;
}
@end

@implementation TestBedViewController

#pragma mark  sounds

- (void) loadSound: (SystemSoundID *) aSound called: (NSString *) aName
{
	NSString *sndpath = [[NSBundle mainBundle] pathForResource:aName ofType:@"aif"];
	CFURLRef baseURL = (CFURLRef)[NSURL fileURLWithPath:sndpath];
    AudioServicesCreateSystemSoundID(baseURL, aSound);
	AudioServicesPropertyID flag = 0;
	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), aSound, sizeof(AudioServicesPropertyID), &flag);
}

- (void) playSound: (SystemSoundID) aSound
{
	AudioServicesPlaySystemSound(aSound);
}

-(void) dealloc
{
	if (sound) AudioServicesDisposeSystemSoundID(sound);
    [super dealloc];
}

#pragma mark AccelerometerHelper

- (IBAction) updateTimeLockout: (UISlider *) slider
{
	timelock.text = [NSString stringWithFormat:@"%4.2f", slider.value];
	[[AccelerometerHelper sharedInstance] setLockout:slider.value];
}

- (IBAction) updateSensitivity: (UISlider *) slider
{
	sensitivity.text = [NSString stringWithFormat:@"%4.2f", slider.value];
	[[AccelerometerHelper sharedInstance] setSensitivity:slider.value];
}

- (void) ping
{
	float change = [[AccelerometerHelper sharedInstance] dAngle];
	acceleration.text = [NSString stringWithFormat:@"%4.2f", change];
}

- (void) shake
{
	float change = [[AccelerometerHelper sharedInstance] dAngle];
	feedback.text = [NSString stringWithFormat:@"Triggered at: %4.2f", change];
	[self playSound:sound];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[AccelerometerHelper sharedInstance].delegate = self;
	[self loadSound:&sound called:@"whoosh"];
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
