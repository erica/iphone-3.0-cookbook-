/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define RSTRING(X) NSStringFromCGRect(X)

#define BASEHEIGHT	284.0f
#define NPAGES		3

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIPageControl *pageControl;
	UIScrollView *sv;
}
@end

@implementation TestBedViewController
- (void) pageTurn: (UIPageControl *) aPageControl
{
	int whichPage = aPageControl.currentPage;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	sv.contentOffset = CGPointMake(320.0f * whichPage, 0.0f);
	[UIView commitAnimations];
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	CGPoint offset = aScrollView.contentOffset;
	pageControl.currentPage = offset.x / 320.0f;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Image Scroller";
	
	// Create the scroll view and set its content size and delegate
	sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, BASEHEIGHT)] autorelease];
	sv.contentSize = CGSizeMake(NPAGES * 320.0f, sv.frame.size.height);
	sv.pagingEnabled = YES;
	sv.delegate = self;
	
	// Load in all the pages
	for (int i = 0; i < NPAGES; i++)
	{
		NSString *filename = [NSString stringWithFormat:@"image%d.png", i+1];
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
		iv.frame = CGRectMake(i * 320.0f, 0.0f, 320.0f, BASEHEIGHT);
		[sv addSubview:iv];
		[iv release];
	}
	
	[self.view addSubview:sv];
	
	pageControl.numberOfPages = 3;
	pageControl.currentPage = 0;
	[pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
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
