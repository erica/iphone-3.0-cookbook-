/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]

@interface TableListViewController : UITableViewController
{
	int count;
	NSMutableArray *items;
	NSUndoManager *undoManager;
}
@property (assign) int count;
@property (retain) NSMutableArray *items;
@property (retain) NSUndoManager *undoManager;
@end

@implementation TableListViewController
@synthesize count;
@synthesize items;
@synthesize undoManager;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return self.items.count;
}

- (void) setBarButtonItems
{
	self.navigationItem.leftBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(addItem:));
	
	if (self.tableView.isEditing)
		self.navigationItem.rightBarButtonItem = SYSBARBUTTON(UIBarButtonSystemItemDone, @selector(leaveEditMode));
	else
		self.navigationItem.rightBarButtonItem = self.items.count ? SYSBARBUTTON(UIBarButtonSystemItemEdit, @selector(enterEditMode)) : nil;
	
	NSMutableArray *barItems = [NSMutableArray array];
	UIBarButtonItem *spacer = SYSBARBUTTON(UIBarButtonSystemItemFixedSpace, nil);
	spacer.width = 64;
	
	[barItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	// Undo button?
	if ([self.undoManager canUndo])	
		[barItems addObject:SYSBARBUTTON(UIBarButtonSystemItemUndo, @selector(undo:))];
	else
		[barItems addObject:spacer];

	[barItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	// Redo button?
	if ([self.undoManager canRedo])	
		[barItems addObject:SYSBARBUTTON(UIBarButtonSystemItemRedo, @selector(redo:))];
	else
		[barItems addObject:spacer];
	
	[barItems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	
	// Create the toolbar
	UIToolbar *tb = [[[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 48.0f)] autorelease];
	tb.barStyle = UIBarStyleBlack;
	tb.tintColor = COOKBOOK_PURPLE_COLOR;
	[tb setItems:barItems animated:YES];
	self.navigationItem.titleView = tb;
}

- (void) undo: (id) sender
{
	[self.undoManager undo];
	[self setBarButtonItems];
}

- (void) redo: (id) sender
{
	[self.undoManager redo];
	[self setBarButtonItems];
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Return a dequeued cell
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
	return cell;
}

- (void) updateItemAtIndexPath: (NSIndexPath *) indexPath withString: (NSString *) string
{
	NSString *undoString = string ? nil : [self.items objectAtIndex:indexPath.row];
	[[self.undoManager prepareWithInvocationTarget:self] updateItemAtIndexPath:indexPath withString:undoString];
	
	// You cannot insert a nil item. Passing nil is a delete request.
	if (!string) 
		[self.items removeObjectAtIndex:indexPath.row];
	else 
		[self.items insertObject:string atIndex:indexPath.row];

	[self.tableView reloadData];
	[self setBarButtonItems];
}

- (void) addItem: (id) sender
{
	// add a new item
	NSIndexPath *newPath = [NSIndexPath indexPathForRow:self.items.count inSection:0];
	NSString *newTitle = [NSString stringWithFormat:@"Item %d", count++];
	[self updateItemAtIndexPath:newPath withString:newTitle];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// delete item
	[self updateItemAtIndexPath:indexPath withString:nil];
}

-(void) tableView: (UITableView *) tableView moveRowAtIndexPath: (NSIndexPath *) oldPath toIndexPath:(NSIndexPath *) newPath
{
	if (oldPath.row == newPath.row) return;

	[[self.undoManager prepareWithInvocationTarget:self] tableView:self.tableView moveRowAtIndexPath:newPath toIndexPath:oldPath];
	
	NSString *item = [[self.items objectAtIndex:oldPath.row] retain];
	[self.items removeObjectAtIndex:oldPath.row];
	[self.items insertObject:item atIndex:newPath.row];
	[item release];

	[self setBarButtonItems];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.25f];
}

-(void)enterEditMode
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
	[self.tableView setEditing:YES animated:YES];
	[self setBarButtonItems];
}

-(void)leaveEditMode
{
	[self.tableView setEditing:NO animated:YES];
	[self setBarButtonItems];
}

- (void) loadView
{
	[super loadView];
	count = 1;
	self.items = [NSMutableArray array];
	[self setBarButtonItems];
	
	self.navigationController.navigationBar.clipsToBounds = YES;
	
	self.undoManager = [[[NSUndoManager alloc] init] autorelease];
	[self.undoManager setLevelsOfUndo:999];
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
