/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "ABContactsHelper.h"
#import "ModalAlert.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController <ABNewPersonViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate>
{
	BOOL doModify;
}
@end

@implementation TestBedViewController
#pragma mark NEW PERSON DELEGATE METHODS
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonViewController didCompleteWithNewPerson:(ABRecordRef)person
{
	if (person)
	{
		// save the edited contact 
		ABContact *contact = [ABContact contactWithRecord:person];
		self.title = [NSString stringWithFormat:@"Updated %@", contact.compositeName];
		[ABContactsHelper addContact:contact withError:nil];
	}
	else
		self.title = @"Cancelled";
	
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PEOPLE PICKER DELEGATE METHODS
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	[self dismissModalViewControllerAnimated:YES];
	[peoplePicker release];
	ABContact *contact = [ABContact contactWithRecord:person];
	
	if (doModify)
	{
		// handle the modification request by pre-filling the new person view controller
		ABNewPersonViewController *npvc = [[ABNewPersonViewController alloc] init];
		npvc.displayedPerson = contact.record;
		npvc.newPersonViewDelegate = self;
		[self.navigationController pushViewController:npvc animated:YES];
		return NO;
	}
	
	// Otherwise assume this is a delete request
	if ([ModalAlert ask:@"Really delete %@?", contact.compositeName])
	{
		self.title = [NSString stringWithFormat:@"Deleted %@", contact.compositeName];
		[contact removeSelfFromAddressBook:nil];
	}
	return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	// required method that is never called in the people-only-picking
	[self dismissModalViewControllerAnimated:YES];
	[peoplePicker release];
	return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissModalViewControllerAnimated:YES];
	[peoplePicker release];
}

#pragma mark Base GUI
- (void) modify
{
	doModify = YES;
	ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
	ppnc.peoplePickerDelegate = self;
	[self presentModalViewController:ppnc animated:YES];
}

- (void) remove
{
	doModify = NO;
	ABPeoplePickerNavigationController *ppnc = [[ABPeoplePickerNavigationController alloc] init];
	ppnc.peoplePickerDelegate = self;
	[self presentModalViewController:ppnc animated:YES];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Modify", @selector(modify));
	self.navigationItem.leftBarButtonItem = BARBUTTON(@"Remove", @selector(remove));
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
