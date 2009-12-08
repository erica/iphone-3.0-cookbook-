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
#define NPAGES		5 // works better with 5 or more. will work with 3 minimum
#define BIGNUM		500

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
	IBOutlet UIPageControl *pageControl;
	UIScrollView *sv;
	int cpage;
}
@end

@implementation TestBedViewController
- (void) updatePagePlacement
{
	CGPoint offset = sv.contentOffset;

	// Current Page
	UIView *v = [sv viewWithTag:900 + cpage];
	CGRect newframe = CGRectMake(offset.x, 0.0f, 320.0f, BASEHEIGHT);
	if (!CGRectEqualToRect(newframe, v.frame)) v.frame = newframe;
	// printf("Center: %d\n", cpage);
	
	// Pages to the left
	int half = (NPAGES / 2);
	float dx = -320.0f * half;
	for (int i = 0; i < half; i++)
	{
		int tag = (cpage + i + NPAGES - half) % NPAGES;
		// printf("Left: %d\n", tag);
		UIView *v = [sv viewWithTag:900 + tag];
		CGRect newframe = CGRectMake(offset.x + dx, 0.0f, 320.0f, BASEHEIGHT);
		if (!CGRectEqualToRect(newframe, v.frame)) v.frame = newframe;
		dx += 320.0f;
	}
	
	// Pages to the right
	int nleft = NPAGES - half;
	dx = 320.0f;
	for (int i = 1; i < nleft; i++)
	{
		int tag = (cpage + i + NPAGES) % NPAGES;
		// printf("Right: %d\n", tag);
		UIView *v = [sv viewWithTag:900 + tag];
		CGRect newframe = CGRectMake(offset.x + dx, 0.0f, 320.0f, BASEHEIGHT);
		if (!CGRectEqualToRect(newframe, v.frame)) v.frame = newframe;
		dx += 320.0f;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGPoint offset = sv.contentOffset;
	int thispage = (int)(offset.x / 320.0f) % NPAGES;
	[self updatePagePlacement];
	cpage = thispage;
}

- (void) scrollViewDidScroll: (UIScrollView *) aScrollView
{
	CGPoint offset = sv.contentOffset;
	cpage = (int)(offset.x / 320.0f) % NPAGES;
	pageControl.currentPage = cpage;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Image Scroller";
	
	// Create the scroll view and set its content size and delegate
	sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, BASEHEIGHT)] autorelease];
	sv.contentSize = CGSizeMake(BIGNUM * 2 * NPAGES * 320.0f, sv.frame.size.height);
	sv.contentOffset = CGPointMake(320.0f * BIGNUM * NPAGES, 0.0f);
	sv.pagingEnabled = YES;
	sv.showsHorizontalScrollIndicator = NO;
	sv.delegate = self;
	
	// Load in all the pages
	for (int i = 0; i < NPAGES; i++)
	{
		NSString *filename = [NSString stringWithFormat:@"image%d.png", ((i % 3) +1)];
		UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
		iv.frame = CGRectMake(0.0f, 0.0f, 320.0f, BASEHEIGHT);
		iv.tag = 900 + i;
		[sv addSubview:iv];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.text = [NSString stringWithFormat:@"Slide %d\n", i + 1];
		label.backgroundColor = [UIColor blackColor];
		label.textColor = [UIColor whiteColor];
		[label sizeToFit];
		label.center = iv.center;
		[iv addSubview:label];
		[label release];
		
		[iv release];
	}
	
	cpage = 0;
	[self updatePagePlacement];
	
	[self.view addSubview:sv];

	pageControl.numberOfPages = NPAGES;
	pageControl.currentPage = 0;
	pageControl.enabled = NO;
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
