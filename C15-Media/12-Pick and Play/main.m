/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, TARGET, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:TARGET action:SELECTOR] autorelease]
#define PLAYER [MPMusicPlayerController iPodMusicPlayer]

@interface TestBedViewController : UIViewController <MPMediaPickerControllerDelegate>
{
	IBOutlet UIToolbar *toolbar;
	IBOutlet UIImageView *imageView;
	MPMediaItemCollection *songs;
}
@property (retain) MPMediaItemCollection *songs;
@end

@implementation TestBedViewController
@synthesize songs;

# pragma mark TOOLBAR CONTENTS
- (NSArray *) playItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemRewind, self, @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemPlay, self, @selector(play))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFastForward, self, @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	
	return items;
}

- (NSArray *) pauseItems
{
	NSMutableArray *items = [NSMutableArray array];
	
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemRewind, self, @selector(rewind))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemPause, self, @selector(pause))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFastForward, self, @selector(fastforward))];
	[items addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil, nil)];
	
	return items;
}

#pragma mark PLAYBACK
- (void) pause
{
	[PLAYER pause];
	toolbar.items = [self playItems];
}

- (void) play
{
	[PLAYER play];
	toolbar.items = [self pauseItems];
}

- (void) fastforward
{
	[PLAYER skipToNextItem];
}

- (void) rewind
{
	[PLAYER skipToPreviousItem];
}


#pragma mark STATE CHANGES
- (void) playbackItemChanged: (NSNotification *) notification
{
	// update title and artwork
	self.title = [PLAYER.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
	MPMediaItemArtwork *artwork = [PLAYER.nowPlayingItem valueForProperty: MPMediaItemPropertyArtwork];
	imageView.image = [artwork imageWithSize:[imageView frame].size];
}

- (void) playbackStateChanged: (NSNotification *) notification
{
	// On stop, clear title, toolbar, artwork
	if (PLAYER.playbackState == MPMusicPlaybackStateStopped)
	{
		self.title = nil;
		toolbar.items = nil;
		imageView.image = nil;
	}
}

#pragma mark MEDIA PICKING
- (void)mediaPicker: (MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
	self.songs = mediaItemCollection;
	[PLAYER setQueueWithItemCollection:self.songs];
	[toolbar setItems:[self playItems]];
	[self dismissModalViewControllerAnimated:YES];
	[mediaPicker release];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
	[self dismissModalViewControllerAnimated:YES];
	[mediaPicker release];
}

- (void) pick: (UIBarButtonItem *) bbi
{
	MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	mpc.delegate = self;
	mpc.prompt = @"Please select items to play";
	mpc.allowsPickingMultipleItems = YES;
	
	[self presentModalViewController:mpc animated:YES];
}


#pragma mark INIT VIEW
- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pick:));
	toolbar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// Stop any ongoing music
	[PLAYER stop];
	
	// Add listeners
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:PLAYER];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackItemChanged:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:PLAYER];
	[PLAYER beginGeneratingPlaybackNotifications];
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

- (void) applicationWillTerminate: (UIApplication *) application
{
	[PLAYER stop];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
