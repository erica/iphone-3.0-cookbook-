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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{ 
	return 1; 
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCellStyle style;
	NSString *cellType;
	
	switch (indexPath.row % 4)
	{
		case 0:
			style = UITableViewCellStyleDefault;
			cellType = @"Default Style";
			break;
		case 1:
			style = UITableViewCellStyleSubtitle;
			cellType = @"Subtitle Style";
			break;
		case 2:
			style = UITableViewCellStyleValue1;
			cellType = @"Value1 Style";
			break;
		case 3:
			style =  UITableViewCellStyleValue2;
			cellType =  @"Value2 Style";
			break;
			
	}
	
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:cellType];
	if (!cell) 
		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellType] autorelease];
	
	if (indexPath.row > 3) 
		cell.imageView.image = [UIImage imageNamed:@"icon.png"];
	
	cell.textLabel.text = cellType;
	cell.detailTextLabel.text = @"Subtitle text";
	return cell;
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{	
	
	TableListViewController *tlvc = [[TableListViewController alloc] init];
	tlvc.tableView.rowHeight = 58;
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
