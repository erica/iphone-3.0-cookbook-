/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

// Offsite resource Betty Boop Cinderella @Archive.org
#define PATHSTRING @"http://www.archive.org/download/bb_poor_cinderella/bb_poor_cinderella_512kb.mp4"

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie=[aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
    [theMovie release];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Play", @selector(play:));
	self.title = nil;
}

- (void) preloadDidFinishCallback: (NSNotification *) aNotification
{
	MPMoviePlayerController* theMovie=[aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerContentPreloadDidFinishNotification object:theMovie];
	theMovie.backgroundColor = [UIColor blackColor];
}

- (void) play: (UIBarButtonItem *) bbi
{
	self.navigationItem.rightBarButtonItem = nil;
	self.title = @"Contacting Server";
	MPMoviePlayerController* theMovie=[[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:PATHSTRING]];
	theMovie.scalingMode = MPMovieScalingModeAspectFill;
	theMovie.backgroundColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:) name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preloadDidFinishCallback:) name:MPMoviePlayerContentPreloadDidFinishNotification object:theMovie];
	[theMovie play];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Play", @selector(play:));
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
