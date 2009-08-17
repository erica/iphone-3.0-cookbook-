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

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@end

@implementation TestBedViewController
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
	if (!error) 
		self.title = @"Saved!";
	else 
		CFShow([error localizedDescription]);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	// recover video URL
	NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
	
	// check if video is compatible with album
	BOOL compatible = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([url path]);
	
	// save
	if (compatible)
		UISaveVideoAtPathToSavedPhotosAlbum([url path], self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
	
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

- (void) recordVideo: (id) sender
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypeCamera;
	ipc.delegate = self;
	ipc.allowsEditing = YES;
	ipc.videoQuality = UIImagePickerControllerQualityTypeMedium;
	ipc.videoMaximumDuration = 30.0f; // 30 seconds
	ipc.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
	// ipc.mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image", nil];
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
	
	if ([self videoRecordingAvailable])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Record", @selector(recordVideo:));
	else 
		self.title = @"No Video Recording";
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
