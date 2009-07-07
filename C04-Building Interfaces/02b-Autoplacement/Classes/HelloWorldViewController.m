#import "HelloWorldViewController.h"

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

@implementation HelloWorldViewController

// recursive descent
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

- (void) viewDidLoad
{
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation 
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIView *template = nil;
	
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
			template = landscapeTemplate;
			break;
        }
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
			template = portraitTemplate;
            break;
        }
        default:
			break;
	}
	
	if (!template) return;
	
	for (UIView *eachView in allSubviews(template))
	{
		int tag = eachView.tag;
		if (tag < 10) continue;
		printf("About to move view %d\n", tag);
		[self.view viewWithTag:tag].frame = eachView.frame;
	}
}
@end
