/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "UIDevice-Reachability.h"
#import "ModalAlert.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

#define PRODUCT_ID	@"com.sadun.scanner.disclosure2"
#define SANDBOX	YES

@interface TestBedViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
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

- (void) repurchase
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	SKProduct *product = [[response products] lastObject];
	if (!product)
	{
		[self doLog:@"Error retrieving product information from App Store. Sorry! Please try again later."];
		return;
	}

	// Retrieve the localized price
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedString = [numberFormatter stringFromNumber:product.price];
	[numberFormatter release];
	
	// Create a description that gives a heads up about 
	// a non-consumable purchase
	NSString *buyString = formattedString; 
	NSString *describeString = [NSString stringWithFormat:@"%@\n\nIf you have already purchased this item, you will not be charged again.", product.localizedDescription];
	NSArray *buttons = [NSArray arrayWithObject: buyString];
	
	// Offer the user a choice to buy or not buy
	if ([ModalAlert ask:describeString withCancel:@"No Thanks" withButtons:buttons])
	{
		// Purchase the item
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:PRODUCT_ID]; 
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		// restore the GUI to provide a buy/purchase button
		// or otherwise to a ready-to-buy state
	}
}

#pragma mark payments
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
}

- (void) completedPurchaseTransaction: (SKPaymentTransaction *) transaction
{
	// PERFORM THE SUCCESS ACTION THAT UNLOCKS THE FEATURE HERE
		
	// Finish transaction
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	[ModalAlert say:@"Thank you for your purchase."];
}

- (void) handleFailedTransaction: (SKPaymentTransaction *) transaction
{
	if (transaction.error.code != SKErrorPaymentCancelled)
		[ModalAlert say:@"Transaction Error. Please try again later."];
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions 
{
	for (SKPaymentTransaction *transaction in transactions) {
		switch (transaction.transactionState) {
			case SKPaymentTransactionStatePurchased: 
			case SKPaymentTransactionStateRestored: 
				[self completedPurchaseTransaction:transaction];
				break;
			case SKPaymentTransactionStateFailed: 
				[self handleFailedTransaction:transaction]; 
				break;
			default: 
				break;
		}
	}
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
	TestBedViewController *tbvc = [[TestBedViewController alloc] init];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tbvc];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:tbvc];
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
