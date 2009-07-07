/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

// Return an exhaustive descent of the view's subviews
NSArray *allSubviews(UIView *aView)
{
	NSArray *results = [aView subviews];
	for (UIView *eachView in [aView subviews])
	{
		NSArray *riz = allSubviews(eachView);
		if (riz) results = [results arrayByAddingObjectsFromArray:riz];
	}
	return results;
}

// Return all views throughout the application
NSArray *allApplicationViews()
{
    NSArray *results = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
	{
		NSArray *riz = allSubviews(window);
        if (riz) results = [results arrayByAddingObjectsFromArray: riz];
	}
    return results;
}

// Return an array of parent views from the window down to the view
NSArray *pathToView(UIView *aView)
{
    NSMutableArray *array = [NSMutableArray arrayWithObject:aView];
    UIView *view = aView;
    UIWindow *window = aView.window;
    while (view != window)
    {
        view = [view superview];
        [array insertObject:view atIndex:0];
    }
    return array;
}

@interface TestBedViewController : UIViewController
@end

@implementation TestBedViewController
- (void) collectViews: (id) sender
{
	// The two subviews of the main view are the image view backsplash
	// and the single label that shows the selected number
	printf("Subviews of the main view:\n");
	CFShow(allSubviews(self.view));
	
	printf("Path to each main subview:\n");
	for (UIView *eachView in allSubviews(self.view))
		CFShow(pathToView(eachView));
	
	// More views than you could dream of! 
	printf("\nAll window subviews:\n");
	CFShow(allApplicationViews());
}

-(void) segmentAction: (UISegmentedControl *) sender
{
	// Update the label with the segment number
	UILabel *label = (UILabel *)[self.view viewWithTag:101];
	[label setText:[NSString stringWithFormat:@"%0d", sender.selectedSegmentIndex + 1]];
}

- (void) loadView
{
	self.view = [[[NSBundle mainBundle] loadNibNamed:@"mainview" owner:self options:nil] lastObject];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// Create the segmented control. Choose one of the three styles
	NSArray *buttonNames = [NSArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", @"Five", @"Six", nil];
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonNames];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar; 
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.momentary = YES;
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
	
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Test", @selector(collectViews:));
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
