#import "HelloWorldViewController.h"

/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

@implementation HelloWorldViewController

- (void)viewDidLoad {
	self.view.frame = [[UIScreen mainScreen] applicationFrame];
	landscapeView.autoresizesSubviews = NO;
	portraitView.autoresizesSubviews = NO;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if ((interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight))
		self.view = landscapeView;
	else if ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown))
		self.view = portraitView;
	return YES;
}

@end

