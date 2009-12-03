/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SETIMAGE(X) [(UIImageView *)self.view setImage:X];
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
	UIImagePickerController *ipc;
	IBOutlet UIView *overlay;
	int count;
	NSTimer *timer;
}
@end

@implementation TestBedViewController
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo; 
{
	if (!error) 
		NSLog(@"Image written to photo album");
	else
		NSLog(@"Error writing to photo album: %@", [error localizedDescription]);
	overlay.alpha = 1.0f;
	[timer invalidate];
	ipc.cameraViewTransform = CGAffineTransformIdentity;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void) rotate
{
	ipc.cameraViewTransform = CGAffineTransformMakeRotation(2.0f*M_PI*((float)count/100.0f));
	count = (count + 10) % 100;
}

- (void) snap: (id) sender
{
	overlay.alpha = 0.0f;
	[ipc takePicture];
	count = 0;
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(rotate) userInfo:nil repeats:YES];
}

- (void) dismiss: (id) sender
{
	[self dismissModalViewControllerAnimated:YES];
	[ipc release];
	ipc = nil;
}

- (void) takePics: (id) sender
{
	ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType =  UIImagePickerControllerSourceTypeCamera;
	ipc.delegate = self;
	ipc.allowsEditing = NO;
	ipc.showsCameraControls = NO;
	ipc.cameraOverlayView = overlay;
	[self presentModalViewController:ipc animated:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			self.navigationItem.rightBarButtonItem = BARBUTTON(@"Camera", @selector(takePics:));
	else
		showAlert(@"This demo relies on camera access, which is not available on this system. Please run this application on a camera-ready device.");
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
