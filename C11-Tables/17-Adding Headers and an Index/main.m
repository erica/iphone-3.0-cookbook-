/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) [self getColor:[[CRAYON componentsSeparatedByString:@"#"] lastObject]]

#define DEFAULTKEYS [self.crayonColors.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]
#define FILTEREDKEYS [self.filteredArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]

#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"

@interface TableListViewController : UITableViewController
{
	NSMutableDictionary *crayonColors;
	NSArray *filteredArray;
	NSMutableArray *sectionArray;
	UISearchBar *searchBar;
	UISearchDisplayController *searchDC;
}
@property (retain) NSMutableDictionary *crayonColors;
@property (retain) NSArray *filteredArray;
@property (retain) NSMutableArray *sectionArray;
@property (retain) UISearchBar *searchBar;
@property (retain) UISearchDisplayController *searchDC;
@end

@implementation TableListViewController
@synthesize crayonColors;
@synthesize filteredArray;
@synthesize sectionArray;
@synthesize searchBar;
@synthesize searchDC;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	if (aTableView == self.tableView) return 26;
	return 1; 
}

// Via Jack Lucky
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar setText:@""]; 
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	if (aTableView == self.tableView) 
	{
		if ([[self.sectionArray objectAtIndex:section] count] == 0) return nil;
		return [NSString stringWithFormat:@"Crayon names starting with '%@'", [[ALPHA substringFromIndex:section] substringToIndex:1]];
	}
	else return nil;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// Normal table
	if (aTableView == self.tableView) return [[self.sectionArray objectAtIndex:section] count];
	
	// Search table
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", self.searchBar.text];
	self.filteredArray = [self.crayonColors.allKeys filteredArrayUsingPredicate:predicate];
	return self.filteredArray.count;
}

// Convert a 6-character hex color to a UIColor object
- (UIColor *) getColor: (NSString *) hexColor
{
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4; 
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];	
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Dequeue or create a cell
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	
	NSString *crayon;
	
	// Retrieve the crayon and its color
	if (aTableView == self.tableView)
		crayon = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else
		crayon = [FILTEREDKEYS objectAtIndex:indexPath.row];

	cell.textLabel.text = crayon;
	if (![crayon hasPrefix:@"White"])
		cell.textLabel.textColor = [self.crayonColors objectForKey:crayon];
	else
		cell.textLabel.textColor = [UIColor blackColor];
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
	if (aTableView == self.tableView)  // regular table
	{
		NSMutableArray *indices = [NSMutableArray arrayWithObject:UITableViewIndexSearch];
		for (int i = 0; i < 26; i++) 
			if ([[self.sectionArray objectAtIndex:i] count])
				[indices addObject:[[ALPHA substringFromIndex:i] substringToIndex:1]];
		// [indices addObject:@"\ue057"]; // <-- using emoji
		return indices;
	}
	else return nil; // search table
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (title == UITableViewIndexSearch) 
	{
		[self.tableView scrollRectToVisible:self.searchBar.frame animated:NO];
		return -1;
	}
	return [ALPHA rangeOfString:title].location;
}

// Respond to user selections by updating tint colors
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *crayon;
	if (aTableView == self.tableView)
		crayon = [[self.sectionArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	else
		crayon = [FILTEREDKEYS objectAtIndex:indexPath.row];
	self.navigationController.navigationBar.tintColor = [self.crayonColors objectForKey:crayon];
	self.searchBar.tintColor = [self.crayonColors objectForKey:crayon];
}

- (void) viewDidLoad
{
	// Prepare the crayon color dictionary
	NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
	NSArray *rawCrayons = [[NSString stringWithContentsOfFile:pathname encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\n"];
	self.crayonColors = [NSMutableDictionary dictionary];
	
	self.sectionArray = [NSMutableArray array];
	for (int i = 0; i < 26; i++) [self.sectionArray addObject:[NSMutableArray array]];
	for (NSString *string in rawCrayons) 
	{
		[self.crayonColors setObject:CRAYON_COLOR(string) forKey:CRAYON_NAME(string)];
		NSUInteger firstLetter = [ALPHA rangeOfString:[string substringToIndex:1]].location;
		if (firstLetter != NSNotFound) [[self.sectionArray objectAtIndex:firstLetter] addObject:CRAYON_NAME(string)];
	}
	
	// Create a search bar
	self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	self.searchBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.searchBar.keyboardType = UIKeyboardTypeAlphabet;
	self.tableView.tableHeaderView = self.searchBar;
	
	// Create the search display controller
	self.searchDC = [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self] autorelease];
	self.searchDC.searchResultsDataSource = self;
	self.searchDC.searchResultsDelegate = self;
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	
	TableListViewController *tlvc = [[TableListViewController alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tlvc];
	nav.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
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
