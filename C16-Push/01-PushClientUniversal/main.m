/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "TestBedViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define TEXTVIEWTAG 1776
#define TRY_PERFORM(THE_OBJECT, THE_SELECTOR) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR] : nil)
#define TRY_PERFORM_WITH_ARG(THE_OBJECT, THE_SELECTOR, THE_ARG) (([THE_OBJECT respondsToSelector:THE_SELECTOR]) ? [THE_OBJECT performSelector:THE_SELECTOR withObject:THE_ARG] : nil)
#define IS_IPHONE			(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_PORTRAIT UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])
#define NAMED_IMAGE(THE_NAME) \
	([UIImage imageNamed:[NSString stringWithFormat:@"%@-%@-%@.png", THE_NAME, IS_IPHONE ? @"iphone" : @"ipad", IS_PORTRAIT ? @"portrait" : @"landscape"]] ?: \
	([UIImage imageNamed:[NSString stringWithFormat:@"%@-%@.png", THE_NAME, IS_IPHONE ? @"iphone" : @"ipad"]] ?: \
	([UIImage imageNamed:[NSString stringWithFormat:@"%@-%@.png", IS_PORTRAIT ? @"portrait" : @"landscape"]] ?: \
	([UIImage imageNamed:[NSString stringWithFormat:@"%@.png", THE_NAME]]))))

NSString *pushStatus ()
{
	return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
		@"Notifications were active for this application" :
		@"Remote notifications were not active for this application";
}

@implementation TestBedViewController
// Fetch the current switch settings
- (NSUInteger) switchSettings
{
	NSUInteger which = 0;
	if ([badge isOn]) which = which | UIRemoteNotificationTypeBadge;
	if ([alert isOn]) which = which | UIRemoteNotificationTypeAlert;
	if ([sound isOn]) which = which | UIRemoteNotificationTypeSound;
	return which;
}

// Change the switches to match reality
- (void) updateSwitches
{
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	[badge setOn:(rntypes & UIRemoteNotificationTypeBadge)];
	[alert setOn:(rntypes & UIRemoteNotificationTypeAlert)];
	[sound setOn:(rntypes & UIRemoteNotificationTypeSound)];
}

#pragma mark Registration and unregistration utilities

// Little hack work-around to catch the end when the confirmation dialog goes away
- (void) confirmationWasHidden: (NSNotification *) notification
{
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
	[self updateSwitches];
}

// Register application for the services set out by the switches
- (void) doOn
{
	if (![self switchSettings])
	{
		textView.text = [NSString stringWithFormat:@"%@\nNothing to register. Skipping.\n(Did you mean to press Unregister instead?)", pushStatus()];
		[self updateSwitches];
		return;
	}
	
	NSString *status = [NSString stringWithFormat:@"%@\nAttempting registration", pushStatus()];
	textView.text = status;
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
}

// Unregister application for all push notifications
- (void) doOff
{
	textView.text = [NSString stringWithFormat:@"%@\nUnregistering.", pushStatus()];
	[[UIApplication sharedApplication] unregisterForRemoteNotifications];
	[self updateSwitches];
}

- (IBAction) switchValueDidChange: (UISwitch *) aSwitch
{
	//no op
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// Update background art when the device is rotated
- (void) setBackgroundArt: (id) sender
{
	imageView.image = NAMED_IMAGE(@"cover");	
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
	self.title = @"Push Client";
	textView.tag = TEXTVIEWTAG;
	
	// Prepare to update art as the orientation changes
	imageView.image = NAMED_IMAGE(@"cover");	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBackgroundArt:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

	// Set up action switches
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Register", @selector(doOn));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Unregister", @selector(doOff));
	[self updateSwitches];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmationWasHidden:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
	
}
	 
-(void) viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
	UINavigationController *nav;
}
@end

@implementation TestBedAppDelegate
- (void) showString: (NSString *) aString
{
	UITextView *tv = (UITextView *)[[[UIApplication sharedApplication]  keyWindow] viewWithTag:TEXTVIEWTAG];
	tv.text = aString;
}

// Retrieve the device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	NSString *results = [NSString stringWithFormat:@"Badge: %@, Alert:%@, Sound: %@",
						 (rntypes & UIRemoteNotificationTypeBadge) ? @"Yes" : @"No", 
						 (rntypes & UIRemoteNotificationTypeAlert) ? @"Yes" : @"No",
						 (rntypes & UIRemoteNotificationTypeSound) ? @"Yes" : @"No"];
	
	NSString *status = [NSString stringWithFormat:@"%@\nRegistration succeeded.\n\nDevice Token: %@\n%@", pushStatus(), deviceToken, results];
	[self showString:status];
	NSLog(@"deviceToken: %@", deviceToken); 
} 

// Provide a user explanation for when the registration fails
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
	NSString *status = [NSString stringWithFormat:@"%@\nRegistration failed.\n\nError: %@", pushStatus(), [error localizedDescription]];
	[self showString:status];
    NSLog(@"Error in registration. Error: %@", error); 
} 

// Handle an actual notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	NSString *status = [NSString stringWithFormat:@"Notification received:\n%@",[userInfo description]];
	[self showString:status];
	CFShow([userInfo description]);
}

// Report the notification payload when launched by alert
- (void) launchNotification: (NSNotification *) notification
{
	[self performSelector:@selector(showString:) withObject:[[notification userInfo] description] afterDelay:1.0f];
}

// Does not work reliably at the time of writing.
/*- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
 // [self performSelector:@selector(showString:) withObject:[launchOptions description] afterDelay:2.0f];
 printf("In launch options\n");
 CFShow(launchOptions);
 return YES;
 }
 */

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	nav = [[UINavigationController alloc] initWithRootViewController:[[[TestBedViewController alloc] init] autorelease]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	
	// Listen for remote notification launches
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchNotification:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

- (void) dealloc
{
	[nav.view removeFromSuperview];	[nav release];	[window release];	[super dealloc];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
