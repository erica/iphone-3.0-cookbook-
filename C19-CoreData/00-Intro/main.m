/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ModalAlert.h"
#import "Department.h"
#import "Person.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define STOREPATH [NSHomeDirectory() stringByAppendingString:@"/Documents/cdintro_00.sqlite"]

@interface TestBedViewController : UIViewController <NSFetchedResultsControllerDelegate>
{
	IBOutlet UITextView *textView;
	NSManagedObjectContext *context;
	NSFetchedResultsController *results;
}
@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *results;
@end

@implementation TestBedViewController
@synthesize context;
@synthesize results;

- (void) initCoreData
{
	NSError *error;
	NSURL *url = [NSURL fileURLWithPath:STOREPATH];
	
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

- (NSDate *) dateFromString: (NSString *) aString
{
	// Return a date from a string
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	formatter.dateFormat = @"MM-dd-yyyy";
	NSDate *date = [formatter dateFromString:aString];
	return date;
}

- (void) addObjects
{
	NSLog(@"Adding preset data");
	
	// Insert objects for department and two people, setting their properties
	Department *department = (Department *)[NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:self.context];
	department.groupName = @"Office of Personnel Management";
	
	Person *person1 = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
	person1.name = @"John Smith";
	person1.birthday = [self dateFromString:@"12-1-1901"];
	person1.department = department;
	
	Person *person2 = (Person *)[NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:self.context];
	person2.name = @"Jane Doe";
	person2.birthday = [self dateFromString:@"4-13-1922"];
	person2.department = department;
	
	department.manager = person1;
	department.members = [NSSet setWithObjects:person1, person2, nil];
	
    // Save the data
	NSError *error;
	if (![self.context save:&error]) NSLog(@"Error: %@", [error localizedDescription]);
}

- (void) fetchObjects
{
	// Create a basic fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"Person" inManagedObjectContext:self.context]];
	
	// Add a sort descriptor
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:nil];
	NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
	[fetchRequest setSortDescriptors:descriptors];
	[sortDescriptor release];
	
	// Init the fetched results controller
	NSError *error;
	self.results = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:@"Root"];
	self.results.delegate = self;
	if (![[self results] performFetch:&error])	NSLog(@"Error: %@", [error localizedDescription]);

	[self.results release];
	[fetchRequest release];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"Controller content did change");
}

- (void) listPeople
{
	[self fetchObjects];
	if (!self.results.fetchedObjects.count) 
	{
		NSLog(@"Database has no people at this time");
		return;
	}
	
	NSLog(@"People:");
	for (Person *person in self.results.fetchedObjects)	
		NSLog(@"%@ : %@", person.name, person.department.groupName);
}

- (void) removeObjects
{
	NSError *error = nil;
	
	// remove all people (if they exist)
	[self fetchObjects];
	if (!self.results.fetchedObjects.count) 
	{
		NSLog(@"No one to delete");
		return;
	}
	
	// remove each person
	for (Person *person in self.results.fetchedObjects)	
	{
		NSLog(@"Deleting %@\n", person.name);
		
		// remove person as manager if necessary
		if (person.department.manager == person) person.department.manager = nil;

		// remove person from department
		// NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF != %@", person];
		// if (person.department.members) person.department.members = [person.department.members filteredSetUsingPredicate:pred];

		// delete the person object
		[self.context deleteObject:person];
	}
	
	// save
	if (![self.context save:&error]) NSLog(@"Error: %@ (%@)", [error localizedDescription], [error userInfo]);
	[self fetchObjects];
}

- (void) refreshContent
{
	NSArray *buttons = [@"Init People*Remove All People" componentsSeparatedByString:@"*"];
	int answer = [ModalAlert ask:@"Do what?" withCancel:@"Cancel" withButtons:buttons];
	
	switch(answer)
	{
		case 1:
			[self removeObjects];
			[self addObjects];
			[self listPeople];
			break;
		case 2:
			[self removeObjects];
			[self listPeople];
			break;
		default:
			break;
	}
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"List", @selector(listPeople));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Data", @selector(refreshContent));
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
