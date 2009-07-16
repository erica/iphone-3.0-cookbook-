/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]
#define MAINLABEL	((UILabel *)self.navigationItem.titleView)

@interface TableListViewController : UITableViewController
@end

@implementation TableListViewController

- (void) scrollViewDidScroll: (UIScrollView *) sv
{
	float percent =  sv.contentOffset.y / sv.contentSize.height;
	percent = 0.25 + 3 * (MAX(MIN(1.0f, percent), 0.0f) / 4.0f);
	
	self.tableView.backgroundColor = [UIColor colorWithRed:percent * 0.20392 green:percent * 0.19607 blue:percent * 0.61176 alpha: 1.0f];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return [UIFont familyNames].count;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"] autorelease];
	cell.textLabel.text = [[UIFont familyNames] objectAtIndex:indexPath.row];
	cell.textLabel.textColor = [UIColor whiteColor];
	return cell;
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
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	
	TableListViewController *tlvc = [[TableListViewController alloc] init];
	float percent = 0.25f;
	tlvc.tableView.backgroundColor = [UIColor colorWithRed:percent * 0.20392 green:percent * 0.19607 blue:percent * 0.61176 alpha: 1.0f];
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
