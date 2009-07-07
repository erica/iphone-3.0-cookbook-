/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define DATAPATH [NSString stringWithFormat:@"%@/Documents/stored.txt", NSHomeDirectory()]

@interface TestBedViewController : UIViewController <UITextViewDelegate>
{
	NSUndoManager *undoManager;
	IBOutlet UITextView *textView;
}
@property (retain) NSUndoManager *undoManager;
@end

@implementation TestBedViewController
@synthesize undoManager;

- (void) performArchive
{
	[[textView text] writeToFile:DATAPATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// Reveal a Done button when editing starts
- (void) textViewDidBeginEditing: (UITextView *) aTextView
{
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(doneEditing:));
}

// Remove the Done button and dismiss the keyboard
- (void) doneEditing: (id) sender
{
	[textView resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
}

// Prepare to resize for keyboard. Courtesy of August Joki
- (void)keyboardWillShow:(NSNotification *)notification;
{
	NSDictionary *userInfo = [notification userInfo];
	CGRect bounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
	// Resize text view
	CGRect aFrame = textView.frame;
	aFrame.size.height -= bounds.size.height;
	textView.frame = aFrame;
}

// Expand textview on keyboard dismissal. Again thanks to August Joki
- (void)keyboardWillHide:(NSNotification *)notification;
{
	NSDictionary *userInfo = [notification userInfo];
	CGRect bounds;
	[(NSValue *)[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&bounds];
	
	// Resize text view
	CGRect aFrame = CGRectMake(0.0f, 0.0f, 320.0f, 416.0f);
	textView.frame = aFrame;
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	
	// initialize text view
	textView.delegate = self;
	textView.font = [UIFont systemFontOfSize:16.0f];
	textView.text = [NSString stringWithContentsOfFile:DATAPATH];
	
	// prepare undo manager
	[[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
	self.undoManager = [[NSUndoManager alloc] init];
	[self.undoManager setLevelsOfUndo:99];
	[self.undoManager release];
	
	// listen for keyboard
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.undoManager = nil;
	[super dealloc];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
{
	TestBedViewController *tbvc;
}
@property (retain) TestBedViewController *tbvc;
@end

@implementation TestBedAppDelegate
@synthesize tbvc;
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.tbvc = [[[TestBedViewController alloc] init] autorelease];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.tbvc];
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
}

- (void) applicationWillTerminate: (UIApplication *) application
{
	[self.tbvc performArchive]; // update the defaults on quit
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"TestBedAppDelegate");
	[pool release];
	return retVal;
}
