/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "UIDevice-Reachability.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#define PRODUCT_ID	@"com.sadun.scanner.disclosure2"
#define SANDBOX	YES

@interface TestBedViewController : UIViewController <SKProductsRequestDelegate>
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

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	[self doLog:@"Error: Could not contact App Store properly, %@", [error localizedDescription]];
}

- (void)requestDidFinish:(SKRequest *)request
{
	// Release the request
	[request release];
	[self doLog:@"Request finished."];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	// Find a product
	SKProduct *product = [[response products] lastObject];
	if (!product)
	{
		[self doLog:@"Error: Could not find matching products"];
		return;
	}
	
	// Retrieve the localized price
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:product.price];
	[numberFormatter release];
	
	// Show the information
	[self doLog:product.localizedTitle];
	[self doLog:product.localizedDescription];
	[self doLog:@"Price: %@", formattedString];
}

- (void) action: (UIBarButtonItem *) bbi
{
	// Init log
	self.log = [NSMutableString string];
	[self doLog:@"Submitting Request... Please wait."];
	
	// Create the product request and start it
	SKProductsRequest *preq = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:PRODUCT_ID]];
	preq.delegate = self;
	[preq start];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Action", @selector(action:));
	
	self.log = [NSMutableString string];
	if (![UIDevice networkAvailable]) 
		[self doLog:@"You are not connected to the network! All StoreKit calls will fail!"];
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
