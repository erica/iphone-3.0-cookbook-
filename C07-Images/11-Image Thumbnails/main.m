/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ImageHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)[self.view viewWithTag:101] setImage:X]
#define SEGMENT	[(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UIImage *fitImage;
	UIImage *centerImage;
	UIImage *fillImage;
}
@property (retain) UIImage *fitImage;
@property (retain) UIImage *centerImage;
@property (retain) UIImage *fillImage;
@end

@implementation TestBedViewController
@synthesize fitImage;
@synthesize centerImage;
@synthesize fillImage;


- (void) switchImage: (id) sender
{
	if (SEGMENT == 0) SETIMAGE(self.fitImage);
	else if (SEGMENT == 1) SETIMAGE(self.centerImage);
	else if (SEGMENT == 2) SETIMAGE(self.fillImage);
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	self.fitImage = [ImageHelper image:image fitInView:[self.view viewWithTag:101]];
	self.centerImage = [ImageHelper image:image centerInView:[self.view viewWithTag:101]];
	self.fillImage = [ImageHelper image:image fillView:[self.view viewWithTag:101]];
	[self switchImage:nil];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
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
	self.title = @"Image Picker";
	
	// Add the smaller thumbnail subview
	UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 300.0f, 264.0f)];
	iv.tag = 101;
	[self.view addSubview:iv];
	[iv release];
	
	// Add a segmented control for fitting options
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"Fit Center Fill" componentsSeparatedByString:@" "]];
	seg.selectedSegmentIndex = 0;
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	[seg addTarget:self action:@selector(switchImage:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.titleView = seg;
	[seg release];
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
