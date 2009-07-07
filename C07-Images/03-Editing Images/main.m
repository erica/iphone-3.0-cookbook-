/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X];

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation TestBedViewController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	CFShow(info);
	SETIMAGE([info objectForKey:@"UIImagePickerControllerEditedImage"]);
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

// Provide 2.x compliance
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:editingInfo];
	[dict setObject:image forKey:@"UIImagePickerControllerEditedImage"];
	[self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

- (void) pickImage: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	ipc.delegate = self;
	ipc.allowsImageEditing = YES;
	[self presentModalViewController:ipc animated:YES];	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickImage:));
	self.title = @"Image Picker";
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
