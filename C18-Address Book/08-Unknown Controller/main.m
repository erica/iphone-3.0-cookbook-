/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <ABUnknownPersonViewControllerDelegate>
{
	NSMutableString *log;
	IBOutlet UITextView *textView;
}
@property (retain) NSMutableString *log;
@property (retain) UITextView *textView;
@end

@implementation TestBedViewController
@synthesize log;
@synthesize textView;

- (void) doLog: (NSString *) formatstring, ...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	NSString *outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self.log appendString:outstring];
	[self.log appendString:@"\n"];
	self.textView.text = self.log;
}

#pragma mark Unknown Person Delegate Methods
- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person
{
	[self.navigationController popViewControllerAnimated:YES];
	[unknownPersonView release];
}

/* - (BOOL)unknownPersonViewController:(ABUnknownPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	// Optional method for handling default action. Return YES to perform the action (like sending e-mail, etc)
	// Return NO, to skip that.
	return NO;
} */

#pragma mark Base GUI
- (void) action: (UIBarButtonItem *) bbi
{
	// Create and prefill object
	ABContact *contact = [ABContact contact];
	NSArray *emails = [NSArray arrayWithObject:[ABContact dictionaryWithValue:@"feedback@ericasadun.com" andLabel:kABWorkLabel]];
	contact.emailDictionaries = emails;
	
	// Create the controller
	ABUnknownPersonViewController *upvc = [[ABUnknownPersonViewController alloc] init];
	upvc.unknownPersonViewDelegate = self;

	// Initialize for create/add
	upvc.allowsActions = NO; // make calls, send text, email, etc
	upvc.allowsAddingToAddressBook = YES; // can add these properties to a new or existing contact
	upvc.alternateName = @"Unknown Person"; // default values for both first and last name
	upvc.message = @"What do you want to do?"; // optional text to display below alternateName
	upvc.displayedPerson = contact.record;

	// Initialize for do action
	/*
	upvc.allowsActions = YES; // make calls, send text, email, etc
	upvc.allowsAddingToAddressBook = NO; // can add these properties to a new or existing contact
	upvc.displayedPerson = contact.record;
	 */
	
	[self.navigationController pushViewController:upvc animated:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
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
