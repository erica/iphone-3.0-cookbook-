/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "SettingsViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@implementation SettingsViewController
@synthesize wrapper;

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Save", @selector(dismiss:));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Cancel", @selector(dismissCancel:));
}

- (void) dismiss: (id) sender
{
	// recover data, save it, and dismiss
	NSString *uname = [username text];
	NSString *pword = [password text];
	
	if (uname) [self.wrapper setObject:uname forKey:(id)kSecAttrAccount];
	if (pword) [self.wrapper setObject:pword forKey:(id)kSecValueData];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) dismissCancel: (id) sender
{
	// dismiss but do not savea
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Back", @selector(dismissCancel:));
	
	// Identifier refers to upcoming recipes that build on this example
	self.wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"SharedTwitter" accessGroup:@"Y93A4XLA79.com.sadun.GenericKeychainSuite"];
	[self.wrapper release];
	
	NSString *uname = [self.wrapper objectForKey:(id)kSecAttrAccount];
	NSString *pword = [self.wrapper objectForKey:(id)kSecValueData];
	
	if (uname) username.text = uname;
	if (pword) password.text = pword;
	
	username.delegate = self;
	password.delegate = self;	
}

- (void) dealloc
{
	username = nil;
	password = nil;
	self.wrapper = nil;
	[super dealloc];
}
@end
