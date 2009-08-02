/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define IMGBARBUTTON(IMAGE, SELECTOR) [[[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SYSBARBUTTON(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]
#define CUSTOMBARBUTTON(VIEW) [[[UIBarButtonItem alloc] initWithCustomView:VIEW] autorelease]

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) action
{
	// no action actually happens
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Toolbars";
	
	UIToolbar *tb = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
	tb.center = CGPointMake(160.0f, 200.0f);
	NSMutableArray *tbitems = [NSMutableArray array];

	[tbitems addObject:BARBUTTON(@"Title", @selector(action))];
	[tbitems addObject:SYSBARBUTTON(UIBarButtonSystemItemAdd, @selector(action))];
	[tbitems addObject:IMGBARBUTTON([UIImage imageNamed:@"TBUmbrella.png"], @selector(action))];
	[tbitems addObject:CUSTOMBARBUTTON([[[UISwitch alloc] init] autorelease])];
	[tbitems addObject:SYSBARBUTTON(UIBarButtonSystemItemFlexibleSpace, nil)];
	[tbitems addObject:IMGBARBUTTON([UIImage imageNamed:@"TBPuzzle.png"], @selector(action))];
	
	// Add fixed 20 pixel width
	UIBarButtonItem *bbi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
	bbi.width = 20.0f;
	[tbitems addObject:bbi];
	
	tb.items = tbitems;
	[self.view addSubview:tb];
	[tb release];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
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
