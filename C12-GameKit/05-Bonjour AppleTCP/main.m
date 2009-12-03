/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ModalAlert.h"
#import "NetReachability.h"
#import "TCPServer.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, TCPServerDelegate, TCPConnectionDelegate>
{
	UIImage *image;
	TCPServer *server;
}
@property (retain) UIImage *image;
@property (retain) TCPServer *server;
@end

@implementation TestBedViewController
@synthesize image;
@synthesize server;

- (void) baseButtons
{
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Choose Image", @selector(pickImage:));
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
		self.navigationItem.rightBarButtonItem = BARBUTTON(@"Camera", @selector(snapImage:));
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
	[(UIImageView *)[self.view viewWithTag:101] setImage:self.image];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
	[self baseButtons];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
	[self baseButtons];
}

- (void) requestImageOfType: (NSString *) type
{
	UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
	ipc.sourceType = [type isEqualToString:@"Camera"] ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
	ipc.delegate = self;
	ipc.allowsImageEditing = NO;
	[self presentModalViewController:ipc animated:YES];	
}

- (void) pickImage: (id) sender
{
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	[self performSelector:@selector(requestImageOfType:) withObject:@"Library" afterDelay:0.5f];
}

- (void) snapImage: (id) sender
{
	self.navigationItem.leftBarButtonItem = nil;
	self.navigationItem.rightBarButtonItem = nil;
	[self performSelector:@selector(requestImageOfType:) withObject:@"Camera" afterDelay:0.5f];
}

- (NSString *) hostname
{
	char baseHostName[256]; // Thanks, Gunnar Larisch
	int success = gethostname(baseHostName, 255);
	if (success != 0) return nil;
	baseHostName[255] = '\0';
	return [NSString stringWithCString:baseHostName encoding:NSUTF8StringEncoding];
}

- (BOOL) server:(TCPServer*)server shouldAcceptConnectionFromAddress:(const struct sockaddr*)address
{
	return [ModalAlert ask:@"Accept remote connection?"];
}

- (void) connectionDidOpen:(TCPConnection*)connection
{
	printf("Connection did open\n");
	if ([connection sendData:UIImageJPEGRepresentation(self.image, 0.75f)])
		printf("Data sent\n");
	[connection invalidate];
}

- (void) server:(TCPServer*)server didOpenConnection:(TCPServerConnection*)connection
{
	[connection setDelegate:self];
}

- (void) viewDidLoad
{
	NetReachability *nr = [[[NetReachability alloc] initWithDefaultRoute:YES] autorelease];
	if (![nr isReachable] || ([nr isReachable] && [nr isUsingCell]))
	{
		[ModalAlert performSelector:@selector(say:) withObject:@"This application requires WiFi. Please enable WiFi in Settings and run this application again." afterDelay:0.5f];
		return;
	}
	
	self.server = [[[TCPServer alloc] initWithPort:0] autorelease];
	[self.server setDelegate:self];
	[self.server startUsingRunLoop:[NSRunLoop currentRunLoop]];
	[self.server enableBonjourWithDomain:@"local" applicationProtocol:@"PictureThrow" name:[self hostname]];

	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	[self baseButtons];
	self.image = [UIImage imageNamed:@"cover320x416.png"];
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
