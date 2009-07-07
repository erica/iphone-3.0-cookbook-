/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

@interface TestBedController : UITableViewController
@end

@implementation TestBedController

/*
 
 DISPLAY A RECURSIVE VIEW HIERARCHY TREE
 
 */

// Recursively travel down the view tree, increasing the indentation level for children
- (void) dumpView: (UIView *) aView atIndent: (int) indent into:(NSMutableString *) outstring
{
	for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	[outstring appendFormat:@"[%2d] %@\n", indent, [[aView class] description]];
	for (UIView *view in [aView subviews]) [self dumpView:view atIndent:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view
- (NSString *) displayViews: (UIView *) aView
{
	NSMutableString *outstring = [[NSMutableString alloc] init];
	[self dumpView: self.view.window atIndent:0 into:outstring];
	return [outstring autorelease];
}

// Show the tree
- (void) displayViews
{
	CFShow([self displayViews: self.view.window]);
}

/*
 
 The following methods are hard-coded to produce the two-item list to match the view 
 hierarchy example in the Views chapter.
 
 This application is basically non-functional, meant only to show view hierarchies.
 
 */

#define DATA_ARRAY	[NSArray arrayWithObjects:@"Pick Up Milk", @"Call Anna", nil]

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
	cell.textLabel.text = [DATA_ARRAY objectAtIndex:[indexPath row]];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	return cell;
}

- (void) loadView
{
	[super loadView];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithTitle:@"Edit" 
											   style:UIBarButtonItemStylePlain 
											   target:self 
											   action:nil] autorelease];
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithTitle:@"New" 
											   style:UIBarButtonItemStylePlain 
											   target:self 
											   action:nil] autorelease];

	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f];
	
	self.title = @"To Do";
	
	[self performSelector:@selector(displayViews) withObject:nil afterDelay:1.0f];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedController alloc] init]];
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
