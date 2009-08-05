/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "XMLParser.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

@interface TreeBrowserController : UITableViewController
{
	TreeNode *root;
}
@property (nonatomic, retain)	TreeNode *root;
@end

@implementation TreeBrowserController
@synthesize root;

- (id) initWithRoot:(TreeNode *) newRoot
{
	if (self = [super init]) 
	{
		self.root = newRoot;
		if (newRoot.key) self.title = newRoot.key;
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.root.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"generic"] autorelease];
	TreeNode *child = [[self.root children] objectAtIndex:[indexPath row]];

	// Set text
	if (child.hasLeafValue)
		cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", child.key, child.leafvalue];
	else
		cell.textLabel.text = child.key;
	
	// Set color
	if (child.isLeaf)
		cell.textLabel.textColor = [UIColor darkGrayColor];
	else
		cell.textLabel.textColor = [UIColor blackColor];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	TreeNode *child = [self.root.children objectAtIndex:[indexPath row]];
	if (child.isLeaf)
	{
		showAlert(@"%@", child.leafvalue);
		return;
	}
	TreeBrowserController *tbc = [[[TreeBrowserController alloc] initWithRoot:child] autorelease];
	[self.navigationController pushViewController:tbc animated:YES];
}

- (void) loadView
{
	[super loadView];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
}

- (void) dealloc
{
	self.root = nil;
	[super dealloc];
}
@end


@interface TreeBrowserAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TreeBrowserAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	TreeNode *root = [[XMLParser sharedInstance] parseXMLFromURL:[NSURL URLWithString:@"http://newsvote.bbc.co.uk/rss/newsonline_uk_edition/sci/tech/rss.xml"]];
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TreeBrowserController alloc] initWithRoot:root]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TreeBrowserAppDelegate");
	[pool release];
	return retVal;
}
