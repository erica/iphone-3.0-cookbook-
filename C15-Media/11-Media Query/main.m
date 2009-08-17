/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define NUMBER(I)	[NSNumber numberWithInt:I]

@interface TestBedViewController : UITableViewController <MPMediaPickerControllerDelegate, UISearchBarDelegate>
{
	NSArray *songCollections;
	NSMutableDictionary *titleCache; 
}
@property (retain) NSArray *songCollections;
@property (retain) NSMutableDictionary *titleCache;
@end

@implementation TestBedViewController
@synthesize songCollections;
@synthesize titleCache;

#pragma mark EXAMPLES FROM WRITEUP

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
	MPMediaPropertyPredicate *mpp = [MPMediaPropertyPredicate predicateWithValue:@"road" forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonContains];
	[query addFilterPredicate:mpp];
	
	NSArray *collections = query.collections;
	NSLog(@"You have %d matching tracks in your library\n", collections.count);
	
	for (MPMediaItemCollection *collection in collections)
	{
		for (MPMediaItem *item in [collection items])
		{
			NSString *song = [item valueForProperty: MPMediaItemPropertyTitle];
			NSString *artist = [item valueForProperty: MPMediaItemPropertyArtist];
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

#pragma mark RECIPE

- (void)searchBarSearchButtonClicked: (UISearchBar *) searchBar
{
	// Hide keyboard
	[searchBar resignFirstResponder];
	
	// Reset the title cache
	self.titleCache = [NSMutableDictionary dictionary];
	
	// Create a new query
	MPMediaQuery *query = [MPMediaQuery songsQuery];
	MPMediaPropertyPredicate *mpp = [MPMediaPropertyPredicate predicateWithValue:searchBar.text forProperty:MPMediaItemPropertyTitle comparisonType:MPMediaPredicateComparisonContains];
	[query addFilterPredicate:mpp];	
	
	// Retrieve the results and reload the table data
	self.songCollections = query.collections;
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return [self.songCollections count];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// To give a sense of the timing
	printf("Retrieving cell %d\n", indexPath.row);
	
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	
	NSString *label = [titleCache objectForKey:NUMBER(indexPath.row)];
	if (!label) 
	{
		MPMediaItem *item = [[[self.songCollections objectAtIndex:indexPath.row] items] lastObject];
		label = [item valueForProperty:MPMediaItemPropertyTitle];
		[titleCache setObject:label forKey:NUMBER(indexPath.row)];
	}
	
	cell.textLabel.text = label;
	return cell;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;

	// Set up the search bar
	UISearchBar *sb = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	sb.autocapitalizationType = UITextAutocapitalizationTypeNone;
	sb.autocorrectionType = UITextAutocorrectionTypeNo;
	sb.backgroundColor = [UIColor clearColor];
	sb.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.titleView = sb;
	sb.delegate = self;
	
	self.titleCache = [NSMutableDictionary dictionary];
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
