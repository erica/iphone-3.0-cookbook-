/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define IMAGEFILE(BASEFILE, MAXNUM) [NSString stringWithFormat:BASEFILE, (random() % MAXNUM) + 1]

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

/* monsterid was inspired by a post by Don Park and the Combinatoric Critters. All graphics were created by Andreas Gohr. 
The source code and the graphics are provided under the Creative Commons Attribution 2.5 License [4] 
If you use this software and/or graphics please link back to http://www.splitbrain.org/go/monsterid */
- (UIImage *) randomImage
{
	CGRect rect = CGRectMake(0.0f, 0.0f, 120.0f, 120.0f);
	UIGraphicsBeginImageContext(CGSizeMake(120.0f, 120.0f));
	
	UIImage *part;
	part = [UIImage imageNamed:IMAGEFILE(@"oldarms_%d.png", 5)];
	[part drawInRect:rect];
	part = [UIImage imageNamed:IMAGEFILE(@"oldlegs_%d.png", 5)];
	[part drawInRect:rect];
	part = [UIImage imageNamed:IMAGEFILE(@"oldbody_%d.png", 15)];
	[part drawInRect:rect];
	part = [UIImage imageNamed:IMAGEFILE(@"oldmouth_%d.png", 10)];
	[part drawInRect:rect];
	part = [UIImage imageNamed:IMAGEFILE(@"oldeyes_%d.png", 15)];
	[part drawInRect:rect];
	part = [UIImage imageNamed:IMAGEFILE(@"oldhair_%d.png", 5)];
	[part drawInRect:rect];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return image;
}

- (void) action: (UIBarButtonItem *) bbi
{
	// Create and prefill object
	ABContact *contact = [ABContact contact];
	contact.image = [self randomImage];
	
	// Create the controller
	ABUnknownPersonViewController *upvc = [[ABUnknownPersonViewController alloc] init];
	upvc.unknownPersonViewDelegate = self;

	// Initialize for create/add
	upvc.allowsActions = NO; // make calls, send text, email, etc
	upvc.allowsAddingToAddressBook = YES; // can add these properties to a new or existing contact
	upvc.message = @"Who does this look like?"; // optional text to display below alternateName
	upvc.displayedPerson = contact.record;
	
	[self.navigationController pushViewController:upvc animated:YES];
}

- (void) viewDidLoad
{
	srandom(time(0));
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
