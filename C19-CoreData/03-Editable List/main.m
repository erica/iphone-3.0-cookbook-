/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ModalAlert.h"
#import "ToDoItem.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]

@class TestBedAppDelegate;

@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSManagedObjectContext *context;
	NSFetchedResultsController *fetchedResultsController;
}
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation TestBedViewController
@synthesize context;
@synthesize fetchedResultsController;

#pragma mark Core Data
- (void) performFetch
{
	// Init a fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDoItem" inManagedObjectContext:self.context];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:100]; // more than needed for this example
	
	// Apply an ascending sort for the items
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"action" ascending:YES selector:nil];
	NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
	[fetchRequest setSortDescriptors:descriptors];
		
	// Init the fetched results controller
	NSError *error;
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"sectionName" cacheName:@"Root"];
    self.fetchedResultsController.delegate = self;
	[self.fetchedResultsController release];
	if (![[self fetchedResultsController] performFetch:&error])	NSLog(@"Error: %@", [error localizedDescription]);

	[fetchRequest release];
	[sortDescriptor release];
}

#pragma mark Table Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	// Return the title for a given section
	NSArray *titles = [self.fetchedResultsController sectionIndexTitles];
	if (titles.count <= section) return @"Error";
	return [titles objectAtIndex:section];
}

#pragma mark Items in Sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve or create a cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic cell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic cell"] autorelease];
	
	// Recover object from fetched results
	NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:@"action"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	// some action here
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return NO; 	// no reordering allowed
}

#pragma mark Data
- (void) setBarButtonItems
{
	// left item is always add
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(add));
	
	// right (edit/done) item depends on both edit mode and item count
	int count = [[self.fetchedResultsController fetchedObjects] count];
	if (self.tableView.isEditing)
		self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
	else
		self.navigationItem.rightBarButtonItem =  count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
}

-(void)enterEditMode
{
	// Start editing
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.tableView setEditing:YES animated:YES];
	[self setBarButtonItems];
}

-(void)leaveEditMode
{
	// finish editing
	[self.tableView setEditing:NO animated:YES];
	[self setBarButtonItems];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// delete request
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		NSError *error = nil;
		[self.context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		if (![self.context save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	}
	
	// update buttons after delete action
	[self setBarButtonItems];
	
	// update sections
	[self performFetch];
}


- (void) add
{
	// request a string to use as the action item
	NSString *todoAction = [ModalAlert ask:@"What Item?" withTextPrompt:@"To Do Item"];
	if (!todoAction || todoAction.length == 0) return;
	
	// build a new item and set its action field
	ToDoItem *item = (ToDoItem *)[NSEntityDescription insertNewObjectForEntityForName:@"ToDoItem" inManagedObjectContext:self.context];
	item.action = todoAction;
	item.sectionName = [[todoAction substringToIndex:1] uppercaseString];
	
	// save the new item
	NSError *error; 
	if (![self.context save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
	
	// update buttons after add
	[self setBarButtonItems];
	
	// update sections
	[self performFetch];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// update table when the contents have changed
	[self.tableView reloadData];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.context = [(TestBedAppDelegate *)[[UIApplication sharedApplication] delegate] context];
	[self performFetch];
	[self setBarButtonItems];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	NSManagedObjectContext *context;
}
@property (nonatomic, retain) NSManagedObjectContext *context;
@end

@implementation TestBedAppDelegate
@synthesize context;
- (void) initCoreData
{
	NSError *error;
	
	// Path to sqlite file. 
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/todo_04.sqlite"];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	// Init the model, coordinator, context
	NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) 
		NSLog(@"Error: %@", [error localizedDescription]);
	else
	{
		self.context = [[[NSManagedObjectContext alloc] init] autorelease];
		[self.context setPersistentStoreCoordinator:persistentStoreCoordinator];
	}
	[persistentStoreCoordinator release];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	[self initCoreData];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
