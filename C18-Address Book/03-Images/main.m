/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

@interface TableListViewController : UITableViewController <ABPersonViewControllerDelegate>
{
	NSArray *filteredArray;
	NSArray *contacts;
	UISearchBar *searchBar;
	UISearchDisplayController *searchDC;
}
@property (retain) NSArray *contacts;
@property (retain) NSArray *filteredArray;
@property (retain) UISearchBar *searchBar;
@property (retain) UISearchDisplayController *searchDC;
@end

@implementation TableListViewController
@synthesize contacts;
@synthesize filteredArray;
@synthesize searchBar;
@synthesize searchDC;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	// Normal table
	if (aTableView == self.tableView) 
		return self.contacts.count;
	
	// Search table
	self.filteredArray = [ABContactsHelper contactsMatchingName:self.searchBar.text];
	return self.filteredArray.count;
}

// Via Jack Lucky
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	[self.searchBar setText:@""]; 
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Dequeue or create a cell
	UITableViewCellStyle style =  UITableViewCellStyleSubtitle;
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	
	NSArray *collection = (aTableView == self.tableView) ? self.contacts : self.filteredArray;
	ABContact *contact = [collection objectAtIndex:indexPath.row];
	cell.textLabel.text = contact.contactName;
	cell.detailTextLabel.text = contact.phonenumbers;
	
	UIGraphicsBeginImageContext(CGSizeMake(45.0f, 45.0f));
	if (contact.image) 
		[contact.image drawInRect:CGRectMake(0.0f, 0.0f, 45.0f, 45.0f)];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	cell.imageView.image = img;
	
	return cell;
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	// Reveal the item that was selected
	if ([ABContact propertyIsMultivalue:property])
	{
		NSArray *array = [ABContact arrayForProperty:property inRecord:person];
		CFShow([array objectAtIndex:identifierForValue]);
	}
	else
	{
		id object = [ABContact objectForProperty:property inRecord:person];
		CFShow([object description]);
	}
	return YES;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ABPersonViewController *pvc = [[[ABPersonViewController alloc] init] autorelease];
	NSArray *collection = (aTableView == self.tableView) ? self.contacts : self.filteredArray;
	ABContact *contact = [collection objectAtIndex:indexPath.row];
	pvc.displayedPerson = contact.record;
	pvc.personViewDelegate = self;
	[[self navigationController] pushViewController:pvc animated:YES];
}

- (void) viewDidLoad
{
	self.contacts = [ABContactsHelper contacts];
	
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
