/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIView-NameExtensions.h"

@interface ViewIndexer : NSObject {
	NSMutableDictionary *tagdict;
	NSInteger count;
}
@property (nonatomic, retain) NSMutableDictionary *tagdict;
@end

@implementation ViewIndexer
@synthesize tagdict;

#pragma mark sharedInstance
static ViewIndexer *sharedInstance = nil;

+(ViewIndexer *) sharedInstance {
    if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (id) init
{
	if (!(self = [super init])) return self;
	self.tagdict = [NSMutableDictionary dictionary];
	count = 10000;
	return self;
}

- (void) dealloc
{
	self.tagdict = nil;
	[super dealloc];
}

#pragma mark registration
// Pull a new number and increase the count
- (NSInteger) pullNumber
{
	return count++;
}

// Check to see if name exists in dictionary
- (BOOL) nameExists: (NSString *) aName
{
	return [self.tagdict objectForKey:aName] != nil;
}

// Pull out first matching name for tag
- (NSString *) nameForTag: (NSInteger) aTag
{
	NSNumber *tag = [NSNumber numberWithInt:aTag];
	NSArray *names = [self.tagdict allKeysForObject:tag];
	if (!names) return nil;
	if ([names count] == 0) return nil;
	return [names objectAtIndex:0];
}

// Return the tag for a registered name. 0 if not found
- (NSInteger) tagForName: (NSString *)aName
{
	NSNumber *tag = [self.tagdict objectForKey:aName];
	if (!tag) return 0;
	return [tag intValue];
}

// Unregistering reverts tag to 0
- (BOOL) unregisterName: (NSString *) aName forView: (UIView *) aView
{
	NSNumber *tag = [self.tagdict objectForKey:aName];
	
	// tag not found
	if (!tag) return NO;
	
	// tag does not match registered name
	if (aView.tag != [tag intValue]) return NO;
	
	aView.tag = 0;
	[self.tagdict removeObjectForKey:aName];
	return YES;
}

// Register a new name. Names will not re-register (unregister first, please).
// If a view is already registered, it is unregistered and re-registered
- (NSInteger) registerName:(NSString *)aName forView: (UIView *) aView
{
	// You cannot re-register an existing name
	if ([[ViewIndexer sharedInstance] nameExists:aName]) return 0;
	
	// Check to see if the view is named already. If so, unregister.
	NSString *currentName = [self nameForTag:aView.tag];
	if (currentName) [self unregisterName:currentName forView:aView];
	
	// Register the existing tag or pull a new tag if aView.tag is 0
	if (!aView.tag) aView.tag = [[ViewIndexer sharedInstance] pullNumber];
	[self.tagdict setObject:[NSNumber numberWithInt:aView.tag] forKey:aName];
	return aView.tag;
}
@end

@implementation UIView (NameExtensions)

#pragma mark Registration
- (NSInteger) registerName: (NSString *) aName
{
	return [[ViewIndexer sharedInstance] registerName:aName forView:self];
}

- (BOOL) unregisterName: (NSString *) aName
{
	return [[ViewIndexer sharedInstance] unregisterName:aName forView:self];
}

#pragma mark Typed Name Retrieval
- (UIView *) viewNamed: (NSString *) aName
{
	NSInteger tag = [[ViewIndexer sharedInstance] tagForName:aName];
	return [self viewWithTag:tag];
}

- (UIAlertView *) alertViewNamed: (NSString *) aName
{
	return (UIAlertView *)[self viewNamed:aName];
}

- (UIActionSheet *) actionSheetNamed: (NSString *) aName
{
	return (UIActionSheet *)[self viewNamed:aName];
}

- (UITableView *) tableViewNamed: (NSString *) aName
{
	return (UITableView *)[self viewNamed:aName];
}

- (UITableViewCell *) tableViewCellNamed: (NSString *) aName
{
	return (UITableViewCell *)[self viewNamed:aName];
}

- (UIImageView *) imageViewNamed: (NSString *) aName
{
	return (UIImageView *)[self viewNamed:aName];
}

- (UIWebView *) webViewNamed: (NSString *) aName
{
	return (UIWebView *)[self viewNamed:aName];
}

- (UITextView *) textViewNamed: (NSString *) aName
{
	return (UITextView *)[self viewNamed:aName];
}

- (UIScrollView *) scrollViewNamed: (NSString *) aName
{
	return (UIScrollView *)[self viewNamed:aName];
}

- (UIPickerView *) pickerViewNamed: (NSString *) aName
{
	return (UIPickerView *)[self viewNamed:aName];
}

- (UIDatePicker *) datePickerNamed: (NSString *) aName
{
	return (UIDatePicker *)[self viewNamed:aName];
}

- (UISegmentedControl *) segmentedControlNamed: (NSString *) aName
{
	return (UISegmentedControl *)[self viewNamed:aName];
}

- (UILabel *) labelNamed: (NSString *) aName
{
	return (UILabel *)[self viewNamed:aName];
}

- (UIButton *) buttonNamed: (NSString *) aName
{
	return (UIButton *)[self viewNamed:aName];
}

- (UITextField *) textFieldNamed: (NSString *) aName
{
	return (UITextField *)[self viewNamed:aName];
}

- (UISwitch *) switchNamed: (NSString *) aName
{
	return (UISwitch *)[self viewNamed:aName];
}

- (UISlider *) sliderNamed: (NSString *) aName
{
	return (UISlider *)[self viewNamed:aName];
}

- (UIProgressView *) progressViewNamed: (NSString *) aName
{
	return (UIProgressView *)[self viewNamed:aName];
}

- (UIActivityIndicatorView *) activityIndicatorViewNamed: (NSString *) aName
{
	return (UIActivityIndicatorView *)[self viewNamed:aName];
}

- (UIPageControl *) pageControlNamed: (NSString *) aName
{
	return (UIPageControl *)[self viewNamed:aName];
}

- (UIWindow *) windowNamed: (NSString *) aName
{
	return (UIWindow *)[self viewNamed:aName];
}

- (UISearchBar *) searchBarNamed: (NSString *) aName
{
	return (UISearchBar *)[self viewNamed:aName];
}

- (UINavigationBar *) navigationBarNamed: (NSString *) aName
{
	return (UINavigationBar *)[self viewNamed:aName];
}

- (UIToolbar *) toolbarNamed: (NSString *) aName
{
	return (UIToolbar *)[self viewNamed:aName];
}

- (UITabBar *) tabBarNamed: (NSString *) aName
{
	return (UITabBar *)[self viewNamed:aName];
}

#ifdef _USE_OS_3_OR_LATER
- (MKMapView *) mapViewNamed: (NSString *) aName
{
	return (MKMapView *)[self viewNamed:aName];
}
#endif
@end