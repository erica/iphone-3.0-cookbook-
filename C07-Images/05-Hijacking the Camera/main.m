/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView-ViewHierarchy.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X];
#define DOCUMENTS_FOLDER [[
#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
	NSString *filename = [[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] lastPathComponent];
	NSString *debugInfo = [NSString stringWithFormat:@"%@:%d\n%s", filename, line, functname];
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:debugInfo delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UIView *plcameraview;
	UIView *navbar;
}
@property (assign) UIView *plcameraview;
@property (assign) UIView *navbar;
@end

@implementation TestBedViewController
@synthesize plcameraview;
@synthesize navbar;

- (void) dismiss: (id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void) takeShot
{
	extern CGImageRef UIGetScreenImage();
	SETIMAGE([UIImage imageWithCGImage:UIGetScreenImage()]);
	
	// When you're doing stop-motion, do not dismiss but restore the navigation bar
	// [self.navbar setAlpha:1.0f];
}

- (void) shoot: (id) sender
{
	[self.navbar setAlpha:0.0f];
	[self performSelector:@selector(takeShot) withObject:nil afterDelay:0.05f];
	[self performSelector:@selector(dismiss:) withObject:nil afterDelay:0.45f];
}

- (void) setup: (UIView *) aView
{
	self.plcameraview = [aView subviewWithClass:NSClassFromString(@"PLCameraView")];
	if (!plcameraview) return;

	NSArray *svarray = [plcameraview subviews];
	for (int i = 1; i < svarray.count; i++)	[[svarray objectAtIndex:i] setAlpha:0.0f];
	
	self.navbar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)] autorelease];
	UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
	navItem.rightBarButtonItem = BARBUTTON(@"Shoot", @selector(shoot:));
	navItem.leftBarButtonItem = BARBUTTON(@"Cancel", @selector(dismiss:));
	
	[(UINavigationBar *)self.navbar pushNavigationItem:navItem animated:NO];
	[plcameraview addSubview:self.navbar];
}

- (void) getStarted: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:ipc animated:YES];	
	[self performSelector:@selector(setup:) withObject:ipc.view afterDelay:0.5f];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		[self getStarted:nil];
	else
		showAlert(@"This demo relies on camera access, which is not available on this system. Please run this application on a camera-ready device.");
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Snap", @selector(getStarted:));
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	[UIApplication sharedApplication].idleTimerDisabled = YES;
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
