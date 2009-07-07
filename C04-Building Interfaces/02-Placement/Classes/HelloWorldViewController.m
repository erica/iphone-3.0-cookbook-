#import "HelloWorldViewController.h"

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

@implementation HelloWorldViewController

- (void) viewDidLoad
{
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	UILabel *flabel = (UILabel *) [self.view viewWithTag:11];
	UILabel *clabel = (UILabel *) [self.view viewWithTag:12];
	UITextField *ffield = (UITextField *) [self.view viewWithTag:101];
	UITextField *cfield = (UITextField *) [self.view viewWithTag:102];
	
	switch (orientation)
	{
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
		{
			flabel.center = CGPointMake(61,114);
			clabel.center = CGPointMake(321, 114);
			ffield.center = CGPointMake(184, 116);
			cfield.center = CGPointMake(418, 116);
			break;
		}
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationPortraitUpsideDown:
		{
			flabel.center = CGPointMake(113, 121);
			clabel.center = CGPointMake(139, 160);
			ffield.center = CGPointMake(236, 123);
			cfield.center = CGPointMake(236, 162);
			break;
		}
		default:
			break;
	}
}

@end
