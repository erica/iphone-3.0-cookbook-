/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	SystemSoundID startSound;
	SystemSoundID endSound;
}
@end

@implementation TestBedViewController

#pragma mark  sounds

- (void) loadSound: (SystemSoundID *) aSound called: (NSString *) aName
{
	NSString *sndpath = [[NSBundle mainBundle] pathForResource:aName ofType:@"wav"];
	CFURLRef baseURL = (CFURLRef)[NSURL fileURLWithPath:sndpath];
    AudioServicesCreateSystemSoundID(baseURL, aSound);
	AudioServicesPropertyID flag = 0;
	AudioServicesSetProperty(kAudioServicesPropertyIsUISound, sizeof(SystemSoundID), aSound, sizeof(AudioServicesPropertyID), &flag);
}

- (void) playSound: (SystemSoundID) aSound
{
		AudioServicesPlaySystemSound(aSound);
}


#pragma mark Shake events are only detectable by the first responder

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resignFirstResponder];
}

#pragma mark Motion catching

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
	if (motion != UIEventSubtypeMotionShake) return;
	[self playSound:startSound];
}

/* Kind of overkill here 
 - (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
 	if (motion != UIEventSubtypeMotionShake) return;
	[self playSound:endSound];
} */

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[self loadSound:&startSound called:@"start"];
	[self loadSound:&endSound called:@"end"];
}

-(void) dealloc
{
    if (startSound) AudioServicesDisposeSystemSoundID(startSound);
	if (endSound) AudioServicesDisposeSystemSoundID(endSound);
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
