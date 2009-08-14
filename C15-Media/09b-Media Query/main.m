/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <MPMediaPickerControllerDelegate>
@end

@implementation TestBedViewController
- (void) albumsQuery: (UIBarButtonItem *) bbi
{
	// Album query
	MPMediaQuery *query = [MPMediaQuery albumsQuery];
	NSArray *collections = query.collections;
	NSLog(@"You have %d albums in your library\n", collections.count);
}

- (void) titleMatch
{
	// Title match search
	MPMediaQuery *query = [[MPMediaQuery alloc] init];
	MPMediaPropertyPredicate *mpp = [MPMediaPropertyPredicate predicateWithValue:@"road" forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonContains];
	[query addFilterPredicate:mpp];
	NSArray *collections = query.collections;
	NSLog(@"You have %d matching tracks in your library\n", collections.count);
}

- (void) songsQuery
{
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	MPMediaPropertyPredicate *mpp = [MPMediaPropertyPredicate 
									 predicateWithValue:@"road" 
									 forProperty:MPMediaItemPropertyTitle     
									 comparisonType:MPMediaPredicateComparisonContains];
	[query addFilterPredicate:mpp];
	
	NSArray *collections = query.collections;
	NSLog(@"You have %d matching tracks in your library\n", 
		  collections.count);
	
	for (MPMediaItemCollection *collection in collections)
	{
		for (MPMediaItem *item in [collection items])
		{
			NSString *song = [item valueForProperty: 
							  MPMediaItemPropertyTitle];
			NSString *artist = [item valueForProperty:
								MPMediaItemPropertyArtist];
			NSLog(@"%@, %@", song, artist);
		}
	}
}

- (void) artistQuery
{
	MPMediaQuery *query = [MPMediaQuery artistsQuery];
	MPMediaPropertyPredicate *mpp = [MPMediaPropertyPredicate predicateWithValue:@"Sa" forProperty:MPMediaItemPropertyArtist comparisonType:MPMediaPredicateComparisonContains];
	[query addFilterPredicate:mpp];
	
	for (MPMediaItemCollection *collection in query.collections)
	{
		MPMediaItem *item = [[collection items] lastObject];
		NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
		NSLog(artist);
	}
}

- (void) action: (UIBarButtonItem *) bbi
{
	[self songsQuery];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
