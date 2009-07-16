/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define ALPHA	[@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "]

@interface TableListViewController : UITableViewController
{
	NSMutableDictionary *stateDictionary;
}
@property (retain) NSMutableDictionary *stateDictionary;
@end

@implementation TableListViewController
@synthesize stateDictionary;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return 26;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Retrieve or create a cell
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	
	// Set cell label
	NSString *key = [@"Row " stringByAppendingString:[ALPHA objectAtIndex:indexPath.row]];
	cell.textLabel.text = key;
	
	// Set cell checkmark
	NSNumber *checked = [self.stateDictionary objectForKey:key];
	if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
	cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	// Recover the cell and key
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	NSString *key = cell.textLabel.text;
	
	// Created an inverted value and store it
	BOOL isChecked = !([[self.stateDictionary objectForKey:key] boolValue]);
	NSNumber *checked = [NSNumber numberWithBool:isChecked];
	[self.stateDictionary setObject:checked forKey:key];
	
	// Update the cell accessory checkmark
	cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
}

- (void) viewDidLoad
{
	self.stateDictionary = [NSMutableDictionary dictionary];
}

- (void) dealloc
{
	self.stateDictionary = nil;
	[super dealloc];
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
