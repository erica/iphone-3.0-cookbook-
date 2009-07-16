/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

@interface TableListViewController : UITableViewController
@end

@implementation TableListViewController
- (TableListViewController *) init
{
	self = [super initWithStyle:UITableViewStyleGrouped]; 
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 2; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	if (section == 0) return 4;
	else if (section == 1) return 2;
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	if (indexPath.section == 0)
	{
		cell = [tView dequeueReusableCellWithIdentifier:@"SwitchCell"];
		if (!cell)
			cell = [[[NSBundle mainBundle] loadNibNamed:@"switchcell" owner:self options:nil] lastObject];
		[(UILabel *)[cell viewWithTag:101] setText:[NSString stringWithFormat:@"Switch %d\n", indexPath.row + 1]];
	} 
	else if (indexPath.section == 1)
	{
		if (indexPath.row == 0)
		{
			cell = [tView dequeueReusableCellWithIdentifier:@"LibertyCell"];
			if (!cell)
				cell = [[[NSBundle mainBundle] loadNibNamed:@"libertycell" owner:self options:nil] lastObject];
		}
		else if (indexPath.row == 1)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SubtitleCell"] autorelease];
			cell.textLabel.text = @"Hello World";
			cell.detailTextLabel.text = @"Subtitle World";
		}
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0) return 80.0f;
	if (indexPath.section == 1)
	{
		if (indexPath.row == 0) return 340.0f;
		if (indexPath.row == 1) return 40.0f;
	}

	return 0.0f;
}

- (void) viewDidLoad
{
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
