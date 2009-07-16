/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "CustomCell.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]
#define MAINLABEL	((UILabel *)self.navigationItem.titleView)

@interface TableListViewController : UITableViewController
@end

@implementation TableListViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return [UIFont familyNames].count;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CustomCell *cell = (CustomCell *)[aTableView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
	{
		cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil] lastObject];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.primaryLabel.text = [[UIFont familyNames] objectAtIndex:indexPath.row];
	cell.secondaryLabel.font = [UIFont fontWithName:cell.primaryLabel.text size:14.0f];
	return (UITableViewCell *) cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString *font = [[UIFont familyNames] objectAtIndex:indexPath.row];
	[MAINLABEL setText:font];
	[MAINLABEL setFont:[UIFont fontWithName:font size:18.0f]];
}

- (void) loadView
{
	[super loadView];
	self.navigationItem.titleView = [[[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 30.0f)] autorelease];
	[MAINLABEL setBackgroundColor:[UIColor clearColor]];
	[MAINLABEL setTextColor:[UIColor whiteColor]];
	[MAINLABEL setTextAlignment:UITextAlignmentCenter];
	
	self.tableView.rowHeight = 74;
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
