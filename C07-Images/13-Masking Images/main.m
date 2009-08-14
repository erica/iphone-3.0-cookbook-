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
#define SEGMENT [(UISegmentedControl *)self.navigationItem.titleView selectedSegmentIndex]

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation TestBedViewController

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];

	UIImage *maskImage;
	if (SEGMENT == 0) maskImage =[ImageHelper frameImage:image withMask:[UIImage imageNamed:@"heartmask.png"]];
	else if (SEGMENT == 1) maskImage =[ImageHelper frameImage:image withMask:[UIImage imageNamed:@"clubmask.png"]];
	else if (SEGMENT == 2) maskImage =[ImageHelper frameImage:image withMask:[UIImage imageNamed:@"diamondmask.png"]];
	else if (SEGMENT == 3) maskImage =[ImageHelper frameImage:image withMask:[UIImage imageNamed:@"spademask.png"]];
	UIImage *fitImage = [ImageHelper image:maskImage fitInSize:CGSizeMake(320.0f, 416.0f)];
	SETIMAGE(fitImage);
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
	self.title = @"Image Masker";
	
	UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:[@"Heart Club Diamond Spade" componentsSeparatedByString:@" "]];
	seg.segmentedControlStyle = UISegmentedControlStyleBar;
	seg.selectedSegmentIndex = 0;
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
