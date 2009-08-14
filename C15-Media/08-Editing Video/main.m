/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X];

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIVideoEditorControllerDelegate>
{
	NSString *vpath;
}
@property (retain) NSString *vpath;
@end

@implementation TestBedViewController
@synthesize vpath;

- (void)videoEditorController:(UIVideoEditorController *)editor didSaveEditedVideoToPath:(NSString *)editedVideoPath
{
	CFShow(editedVideoPath);

	// can do save here. the data has *not* yet been saved to the photo album
	
	[self dismissModalViewControllerAnimated:YES];
	[editor release];
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor
{
	[self dismissModalViewControllerAnimated:YES];
	[editor release];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error
{
	[self dismissModalViewControllerAnimated:YES];
	[editor release];
	
	NSLog(@"Fail! %@", [error localizedDescription]);
}

- (void) doEdit
{
	if (![UIVideoEditorController canEditVideoAtPath:self.vpath])
	{
		self.title = @"Cannot Edit Video";
		printf("Cannot edit vid at path\n");
		return;
	}
	
	// Can edit 
	UIVideoEditorController *vec = [[UIVideoEditorController alloc] init];
	vec.videoPath = self.vpath;
	vec.delegate = self;
	[self presentModalViewController:vec animated:YES];	
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// recover video URL
	NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
	
	CFShow([url path]);	
	self.vpath = [url path];
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Edit", @selector(doEdit));
}

- (void) pickVideo: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
	ipc.delegate = self;
	ipc.allowsEditing = NO;
	ipc.videoQuality = UIImagePickerControllerQualityTypeMedium;
	ipc.videoMaximumDuration = 30.0f; // 30 seconds
	ipc.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
	[self presentModalViewController:ipc animated:YES];	
}

- (BOOL) videoRecordingAvailable
{
	if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return NO;
	return [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:@"public.movie"];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Pick", @selector(pickVideo:));
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
