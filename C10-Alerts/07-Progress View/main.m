/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define LARGE_STRING @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. In semper, urna vel viverra volutpat, nunc sem dictum risus, sed pharetra eros nunc sit amet libero. Fusce sit amet turpis et est viverra egestas. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Sed id commodo lectus. Donec hendrerit risus et neque semper semper. Fusce eget dui sem, vel consectetur mauris. Fusce tristique lorem a arcu sodales non tristique dui rhoncus. Ut at libero nibh, eu faucibus ipsum. Curabitur congue placerat mi, condimentum faucibus sapien lobortis vel. Sed vulputate lectus ut lacus aliquam tincidunt. Etiam felis ligula, mollis id pretium et, faucibus non sapien. Nulla et sem justo, vitae feugiat orci. Morbi eros est, iaculis a congue nec, sodales at nunc. Morbi tempus consequat tellus vitae viverra. Suspendisse venenatis turpis ut erat elementum facilisis adipiscing ac enim."

@interface TestBedViewController : UIViewController <UIActionSheetDelegate>
{
	float amountDone;
	UIProgressView *progressView;
	UIActionSheet *actionSheet;
}
@property (retain) UIActionSheet *actionSheet;
@end

@implementation TestBedViewController
@synthesize actionSheet;

// This callback fakes progress via setProgress:
- (void) incrementBar: (id) timer
{
    amountDone += 1.0f;
    [progressView setProgress: (amountDone / 20.0)];
	if (amountDone > 20.0) 
	{
		[self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
		self.actionSheet = nil;
		[timer invalidate];
	}
}

// Load the progress bar onto an actionsheet backing
-(void) action: (UIBarButtonItem *) item
{
	amountDone = 0.0f;
    self.actionSheet = [[[UIActionSheet alloc] initWithTitle:@"Downloading data. Please Wait\n\n\n" delegate:nil cancelButtonTitle:nil destructiveButtonTitle: nil otherButtonTitles: nil] autorelease];
	progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0.0f, 40.0f, 220.0f, 90.0f)];
    [progressView setProgressViewStyle: UIProgressViewStyleDefault];
    [actionSheet addSubview:progressView];
    [progressView release];
	
	
    // Create the demonstration updates
    [progressView setProgress:(amountDone = 0.0f)];
	[NSTimer scheduledTimerWithTimeInterval: 0.35 target: self selector:@selector(incrementBar:) userInfo: nil repeats: YES];
    [actionSheet showInView:self.view];
	progressView.center = CGPointMake(actionSheet.center.x, progressView.center.y);	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) orientation
{
	return YES;
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
