/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ModalAlert.h"
#import "Crayon.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]

@class TestBedAppDelegate;

@interface TestBedViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSManagedObjectContext *context;
	NSFetchedResultsController *results;
}
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *results;
@end

@implementation TestBedViewController
@synthesize context;
@synthesize results;

#pragma mark Core Data
- (void) performFetch
{
	// Init a fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Crayon" inManagedObjectContext:self.context];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchBatchSize:100]; // more than needed for this example
	
	// Apply an ascending sort for the color items
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:nil];
	NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
	[fetchRequest setSortDescriptors:descriptors];
		
	// Init the fetched results controller
	NSError *error;
	self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"section" cacheName:@"Root"];
    self.results.delegate = self;
	[self.results release];
	if (![self.results performFetch:&error])	NSLog(@"Error: %@", [error localizedDescription]);

	[fetchRequest release];
	[sortDescriptor release];
}

- (void) addColorToDB: (NSString *) colorString
{
	NSError *error; 

	// Extract the color/name pair
	NSArray *colorComponents = [colorString componentsSeparatedByString:@"#"];
	if (colorComponents.count != 2) return;
	
	// Store a name/color pair into the database
	Crayon *item = (Crayon *)[NSEntityDescription insertNewObjectForEntityForName:@"Crayon" inManagedObjectContext:self.context];
	item.color = [colorComponents objectAtIndex:1];
	item.name = [colorComponents objectAtIndex:0];
	item.section = [item.name substringToIndex:1];
	if (![self.context save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
}

- (void) initCoreData
{
	NSError *error;

	// Path to sqlite file. If the file is not already found, then it needs building
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/Documents/colors_02.sqlite"];
	NSURL *url = [NSURL fileURLWithPath:path];
	BOOL needsBuilding = ![[NSFileManager defaultManager] fileExistsAtPath:path];
	
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
	
	if (needsBuilding)
	{
		NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
		NSArray *crayons = 	[[NSString stringWithContentsOfFile:pathname] componentsSeparatedByString:@"\n"];
		for (NSString *colorString in crayons) [self addColorToDB:colorString];
	}

	// Perform the data fetch
	[self performFetch];
}

#pragma mark Table
- (UIColor *) getColor: (NSString *) hexColor
{
	// Convert a hex color string into a UIColor instance
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Retrieve or create a cell
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basic cell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"basic cell"] autorelease];
	
	// Recover object from fetched results
	NSManagedObject *managedObject = [self.results objectAtIndexPath:indexPath];
	cell.textLabel.text = [managedObject valueForKey:@"name"];
	UIColor *color = [self getColor:[managedObject valueForKey:@"color"]];
	cell.textLabel.textColor = ([[managedObject valueForKey:@"color"] hasPrefix:@"FFFFFF"]) ? [UIColor blackColor] : color;
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// When a row is selected, color the navigation bar accordingly
	NSManagedObject *managedObject = [self.results objectAtIndexPath:indexPath];
	UIColor *color = [self getColor:[managedObject valueForKey:@"color"]];
	self.navigationController.navigationBar.tintColor = color;
}

#pragma mark Sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	// Use the fetched results section count
	return [[self.results sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	// Return  the count for each section
	return [[[self.results sections] objectAtIndex:section] numberOfObjects];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView 
{
	// Return the array of section index titles
	return self.results.sectionIndexTitles;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
	// Return the title for a given section
	NSArray *titles = [self.results sectionIndexTitles];
	if (titles.count <= section) return @"Error";
	return [titles objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	// Query the titles for the section associated with an index title
	return [self.results.sectionIndexTitles indexOfObject:title];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// On load, initialize the core data elements
	[self initCoreData];
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
