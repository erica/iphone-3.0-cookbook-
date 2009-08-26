/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]
#define CRAYON_NAME(CRAYON)	[[CRAYON componentsSeparatedByString:@"#"] objectAtIndex:0]
#define CRAYON_COLOR(CRAYON) [self getColor:[[CRAYON componentsSeparatedByString:@"#"] lastObject]]

@interface NSString (sortingExtension)
@end
@implementation NSString (sortingExtension)
- (NSComparisonResult) reverseCompare: (NSString *) aString
{
	return -1 * [self caseInsensitiveCompare:aString];
}

- (NSComparisonResult) lengthCompare: (NSString *) aString
{
	if (self.length == aString.length) return NSOrderedSame;
	if (self.length > aString.length) return NSOrderedDescending;
	return NSOrderedAscending;
}
@end



@interface TableListViewController : UITableViewController
{
	NSArray *items;
}
@property (retain) NSArray *items;
@end

@implementation TableListViewController
@synthesize items;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return items.count;
}

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

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"] autorelease];
	NSString *crayon = [items objectAtIndex:indexPath.row];
	cell.textLabel.text = CRAYON_NAME(crayon);
	if (![CRAYON_NAME(crayon) hasPrefix:@"White"])
		cell.textLabel.textColor = CRAYON_COLOR(crayon);
	else
		cell.textLabel.textColor = [UIColor blackColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *crayon = [self.items objectAtIndex:indexPath.row];
	self.navigationController.navigationBar.tintColor = CRAYON_COLOR(crayon);
}

- (void) updateSort: (UISegmentedControl *) seg
{
	if (seg.selectedSegmentIndex == 0)
		self.items = [self.items sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	else if (seg.selectedSegmentIndex == 1)
		self.items = [self.items sortedArrayUsingSelector:@selector(reverseCompare:)];
	else if (seg.selectedSegmentIndex == 2)
		self.items = [self.items sortedArrayUsingSelector:@selector(lengthCompare:)];

	[self.tableView reloadData];
}

- (void) viewDidLoad
{
	NSString *pathname = [[NSBundle mainBundle]  pathForResource:@"crayons" ofType:@"txt" inDirectory:@"/"];
	self.items = [[NSString stringWithContentsOfFile:pathname] componentsSeparatedByString:@"\n"];
	
	UISegmentedControl *seg = [[[UISegmentedControl alloc] initWithItems:[@"Ascending Descending Length" componentsSeparatedByString:@" "]] autorelease];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
	[seg addTarget:self action:@selector(updateSort:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = seg;
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
