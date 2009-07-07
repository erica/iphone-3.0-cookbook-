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

- (NSString *) findUniqueSavePath
{
	int i = 1;
	NSString *path; 
	do {
		// iterate until a name does not match an existing file
	    path = [NSString stringWithFormat:@"%@/Documents/IMAGE_%04d.PNG", NSHomeDirectory(), i++];
	} while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
	
	return path;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];

	// Write to file
	// [UIImageJPEGRepresentation(image, 1.0f) writeToFile:[self findUniqueSavePath] atomically:YES];
	[UIImagePNGRepresentation(image) writeToFile:[self findUniqueSavePath] atomically:YES];

	// Set the background
	SETIMAGE(image);

	// Show the current contents of the documents folder
	CFShow([[NSFileManager defaultManager] directoryContentsAtPath:[NSHomeDirectory() stringByAppendingString:@"/Documents"]]);
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
