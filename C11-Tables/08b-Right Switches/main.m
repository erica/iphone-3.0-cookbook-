/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "CustomCell.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define ALPHA [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "]

@interface TableListViewController : UITableViewController
{
	NSMutableDictionary *switchStates;
}
@property (retain) NSMutableDictionary *switchStates;
@end

@implementation TableListViewController
@synthesize switchStates;

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
	CustomCell *cell = (CustomCell *)[tView dequeueReusableCellWithIdentifier:@"BaseCell"];
	if (!cell) 
		cell = [[[NSBundle mainBundle] loadNibNamed:@"BaseCell" owner:self options:nil] lastObject];
	
	NSString *key = [ALPHA objectAtIndex:indexPath.row];
	cell.customLabel.text = key;
	cell.tableViewController = self;
	if (self.switchStates)
	{
		NSNumber *state;
		if (state = [self.switchStates objectForKey:key])
			cell.customSwitch.on = [state boolValue];
		else
		{
			cell.customSwitch.on = YES;
			[self.switchStates setObject:[NSNumber numberWithBool:YES] forKey:key];
		}
	}

	return (UITableViewCell *)cell;
}

- (void) updateSwitch:(UISwitch *) aSwitch forItem: (NSString *) anItem
{
	if (self.switchStates)
		[self.switchStates setObject:[NSNumber numberWithBool:aSwitch.on] forKey: anItem];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
}

- (void) viewDidLoad
{
	self.switchStates = [NSMutableDictionary dictionary];
}

- (void) dealloc
{
	self.switchStates = nil;
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
