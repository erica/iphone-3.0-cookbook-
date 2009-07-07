/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define TEXTVIEWTAG	11

#pragma mark Notification types utility

NSString *pushStatus ()
{
	return [[UIApplication sharedApplication] enabledRemoteNotificationTypes] ?
	@"Notifications were active for this application" :
	@"Remote notifications were not active for this application";
}

@interface TestBedController : UIViewController
@end

@implementation TestBedController

#pragma mark Switch settings utilities

// Fetch the current switch settings
- (NSUInteger) switchSettings
{
	NSUInteger which = 0;
	if ([(UISwitch *)[self.view viewWithTag:101] isOn]) which = which | UIRemoteNotificationTypeBadge;
	if ([(UISwitch *)[self.view viewWithTag:102] isOn]) which = which | UIRemoteNotificationTypeAlert;
	if ([(UISwitch *)[self.view viewWithTag:103] isOn]) which = which | UIRemoteNotificationTypeSound;
	return which;
}

// Change the switches to match reality
- (void) updateSwitches
{
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	[(UISwitch *)[self.view viewWithTag:101] setOn:(rntypes & UIRemoteNotificationTypeBadge)];
	[(UISwitch *)[self.view viewWithTag:102] setOn:(rntypes & UIRemoteNotificationTypeAlert)];
	[(UISwitch *)[self.view viewWithTag:103] setOn:(rntypes & UIRemoteNotificationTypeSound)];
}


#pragma mark Registration and unregistration utilities

// Little hack work-around to catch the end when the confirmation dialog goes away
- (void) confirmationWasHidden: (NSNotification *) notification
{
	// A secondary registration helps work through early 3.0 beta woes. It costs nothing and has no
	// ill side effects, so can be used without worry.
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
	[self updateSwitches];
}

// Register application for the services set out by the switches
- (void) doOn
{
	UITextView *tv = (UITextView *)[self.view viewWithTag:TEXTVIEWTAG];
	if (![self switchSettings])
	{
		tv.text = [NSString stringWithFormat:@"%@\nNothing to register. Skipping.\n(Did you mean to press Unregister instead?)", pushStatus()];
		[self updateSwitches];
		return;
	}
		
	NSString *status = [NSString stringWithFormat:@"%@\nAttempting registration", pushStatus()];
	tv.text = status;
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:[self switchSettings]];
}

// Unregister application for all push notifications
- (void) doOff
{
	UITextView *tv = (UITextView *)[self.view viewWithTag:TEXTVIEWTAG];
	NSString *status = [NSString stringWithFormat:@"%@\nUnregistering.", pushStatus()];
	tv.text = status;
	
	[[UIApplication sharedApplication] unregisterForRemoteNotifications];
	[self updateSwitches];
}

#pragma mark View setup

- (void)loadView
{
	self.view = [[[NSBundle mainBundle] loadNibNamed:@"view" owner:self options:NULL] objectAtIndex:0];
	self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f];
	self.title = @"Push Client";
	
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Register", @selector(doOn));
	
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Unregister", @selector(doOff));
	[self updateSwitches];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confirmationWasHidden:) name:@"UIApplicationDidBecomeActiveNotification" object:nil];
}
@end

@interface SampleAppDelegate : NSObject <UIApplicationDelegate> 
@end

@implementation SampleAppDelegate

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
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedController alloc] init]];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	
	// Listen for remote notification launches
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(launchNotification:) name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"SampleAppDelegate");
	[pool release];
	return retVal;
}