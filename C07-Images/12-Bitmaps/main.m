/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ImageHelper.h"
#import "ImageHelper-ImageProcessing.h"
#import "ModalHUD.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X];

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UIImage *original;
	UIImage *processed;
}
@property (retain) UIImage *original;
@property (retain) UIImage *processed;
@end

@implementation TestBedViewController
@synthesize original;
@synthesize processed;

- (void) swap
{
	if ([(UIImageView *)self.view image] == self.original) SETIMAGE(self.processed) else SETIMAGE(self.original);
}

- (void) dismissHUD
{
	if (![ModalHUD dismiss])
		[self performSelector:@selector(dismissHUD) withObject:nil afterDelay:0.2f];
}

- (void) finish
{
	SETIMAGE(self.processed);
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Swap", @selector(swap));
	[self dismissHUD];
}

- (void) process
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	CGSize coreSize = CGSizeMake(320.0f, 416.0f);
	UIGraphicsBeginImageContext(coreSize);
	[self.original drawInRect:[ImageHelper frameSize:self.original.size inSize:coreSize]];
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	self.original = newimg;
	self.processed = [ImageHelper convolveImageWithEdgeDetection:self.original];
	[self performSelectorOnMainThread:@selector(finish) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.original = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
	[ModalHUD performSelector:@selector(showHUD:) withObject:@"Processing\nPlease wait." afterDelay:0.01f];
	[NSThread detachNewThreadSelector:@selector(process) toTarget:self withObject:nil];
}

// Provide 2.x compliance
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
	[self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

- (void) pickImage: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	ipc.delegate = self;
	ipc.allowsImageEditing = NO;
	[self presentModalViewController:ipc animated:YES];	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickImage:));
	self.title = @"Edge Detection";
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
