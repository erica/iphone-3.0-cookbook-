/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "TwitPicOperation.h"
#import "KeychainItemWrapper.h"
#import "ImageHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

@interface TestBedViewController : UIViewController <TwitPicOperationDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	IBOutlet UIButton *button;
	IBOutlet UIImageView *imageView;
	IBOutlet UIActivityIndicatorView *activity;
	UIImage *image;
	KeychainItemWrapper *wrapper;
}
@property (retain) UIImage *image;
@property (retain) KeychainItemWrapper *wrapper;
@end

@implementation TestBedViewController
@synthesize wrapper;
@synthesize image;

- (void) hideButtons
{
	self.navigationItem.rightBarButtonItem = nil;
	self.navigationItem.leftBarButtonItem = nil;
}

- (void) showButtons
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Upload", @selector(tweet:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Settings", @selector(settings:));
}

- (void) doneTweeting : (NSString *) outstring
{
	[activity stopAnimating];
	showAlert(outstring);
	[button setEnabled:YES];
	[self showButtons];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	self.image = [ImageHelper image:img fillSize:(CGSizeMake(320.0f, 480.0f))];
	UIImage *thumb = [ImageHelper image:self.image fitInSize:imageView.frame.size];
	imageView.image = thumb;
	
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void) loadPicture: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	ipc.delegate = self;
	ipc.allowsImageEditing = NO;
	[self presentModalViewController:ipc animated:YES];	
}

- (void) tweet: (UIBarButtonItem *) bbi
{
	if (!self.image)
	{
		showAlert(@"Please select image before uploading.");
		return;
	}
	
	[self hideButtons];
	button.enabled = NO;
	[activity startAnimating];
	
	TwitPicOperation *operation = [[[TwitPicOperation alloc] init] autorelease];
	operation.delegate = self;
	operation.theImage = self.image;
	
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:operation];
}

- (void) settings: (UIBarButtonItem *) bbi
{
	SettingsViewController *svc = [[[SettingsViewController alloc] init] autorelease];
	svc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:svc] autorelease];
	[self.navigationController presentModalViewController:nav animated:YES];
}

- (void) viewDidAppear: (BOOL) animated
{
	NSString *uname = [wrapper objectForKey:(id)kSecAttrAccount];
	NSString *pword = [wrapper objectForKey:(id)kSecValueData];
	if (uname && pword)
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Upload", @selector(tweet:));
}

- (void) viewDidLoad
{
	self.title = @"iTweet";
	self.wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Twitter" accessGroup:nil];
	[self.wrapper release];
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Settings", @selector(settings:));
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
