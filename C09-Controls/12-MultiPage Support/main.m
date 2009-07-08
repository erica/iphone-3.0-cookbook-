/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define RSTRING(X) NSStringFromCGRect(X)

#define BASEHEIGHT	281.0f
#define INITPAGES	3
#define MAXPAGES	8

@interface TestBedViewController : UIViewController <UIScrollViewDelegate>
{
	UIScrollView *sv;
	IBOutlet UIPageControl *pageControl;
	IBOutlet UIButton *addButton;
	IBOutlet UIButton *cancelButton;
	IBOutlet UIButton *confirmButton;
	IBOutlet UIButton *deleteButton;
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

- (UIColor *)randomColor
{
	float red = (64 + (random() % 191)) / 256.0f;
	float green = (64 + (random() % 191)) / 256.0f;
	float blue = (64 + (random() % 191)) / 256.0f;
	return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}

- (void) addPage
{
	pageControl.numberOfPages = pageControl.numberOfPages + 1;
	pageControl.currentPage = pageControl.numberOfPages - 1;
	
	sv.contentSize = CGSizeMake(pageControl.numberOfPages * 320.0f, BASEHEIGHT);
	UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(pageControl.currentPage * 320.0f, 0.0f, 320.0f, BASEHEIGHT)];
	aView.backgroundColor = [self randomColor];
	[sv addSubview:aView];
	[aView release];
}

- (void) requestAdd: (UIButton *) button
{
	[self addPage];
	addButton.enabled = (pageControl.numberOfPages < 8) ? YES : NO;
	deleteButton.enabled = YES;
	[self pageTurn:pageControl];
}

- (void) deletePage
{
	int whichPage = pageControl.currentPage;
	pageControl.numberOfPages = pageControl.numberOfPages - 1;
		
	// remove the view in question
	NSMutableArray *properViews = [NSMutableArray array];
	for (UIView *view in sv.subviews)
		if ([[[view class] description] isEqualToString:@"UIView"] &&
			(view.frame.size.width == 320.0f))
			[properViews addObject:view];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	

	UIView *whichView = [properViews objectAtIndex:whichPage];

	// move other pages into place
	for (int i = whichPage + 1; i < [properViews count]; i++)
	{
		UIView *aView = [properViews objectAtIndex:i];
		CGRect frame = aView.frame;
		frame.origin.x = frame.origin.x - 320.0f;
		aView.frame = frame;
	}
	
	[UIView commitAnimations];
	
	[whichView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.3f];

	sv.contentSize = CGSizeMake(sv.contentSize.width - 320.0f, BASEHEIGHT);
}

- (void) hideConfirmAndCancel
{
	cancelButton.enabled = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	confirmButton.center = CGPointMake(deleteButton.center.x + 100.0f, deleteButton.center.y);
	[UIView commitAnimations];
}

- (void) confirmDelete: (UIButton *) button
{
	[self deletePage];
	addButton.enabled = YES;
	deleteButton.enabled = (pageControl.numberOfPages > 1) ? YES : NO;
	[self pageTurn:pageControl];
	[self hideConfirmAndCancel];
}

- (void) cancelDelete: (UIButton *) button
{
	[self hideConfirmAndCancel];
}

- (void) requestDelete: (UIButton *) button
{
	// Bring forth the cancel and confirm buttons
	[cancelButton.superview bringSubviewToFront:cancelButton];
	[confirmButton.superview bringSubviewToFront:confirmButton];
	cancelButton.enabled = YES;

	// Animate the confirm button into place
	confirmButton.center = CGPointMake(deleteButton.center.x + 100.0f, deleteButton.center.y);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	confirmButton.center = deleteButton.center;
	[UIView commitAnimations];
}

- (void) viewDidLoad
{
	// Initialize random seed
	srandom(time(0));
	
	// Set up display
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Super Paged Scroller";
	
	// Create the scroll view and set its content size and delegate
	sv = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, BASEHEIGHT)] autorelease];
	sv.contentSize = CGSizeZero;
	sv.pagingEnabled = YES;
	sv.delegate = self;
	[self.view addSubview:sv];
	
	pageControl.numberOfPages = 0;
	[pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];

	// Load in all the pages
	for (int i = 0; i < INITPAGES; i++) [self addPage];
	pageControl.currentPage = 0;
	
	// Increase the size of the add button
	CGRect frame = addButton.frame;
	CGPoint center = addButton.center;
	frame.size = CGSizeMake(80.0f, 80.0f);
	addButton.frame = frame;
	addButton.center = center;
	
	[addButton addTarget:self action:@selector(requestAdd:) forControlEvents:UIControlEventTouchUpInside];
	[cancelButton addTarget:self action:@selector(cancelDelete:) forControlEvents:UIControlEventTouchUpInside];
	[deleteButton addTarget:self action:@selector(requestDelete:) forControlEvents:UIControlEventTouchUpInside];
	[confirmButton addTarget:self action:@selector(confirmDelete:) forControlEvents:UIControlEventTouchUpInside];
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
