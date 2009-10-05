/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@interface SettingsViewController : UIViewController <UITextFieldDelegate>
{
	IBOutlet UITextField *username;
	IBOutlet UITextField *password;
	KeychainItemWrapper *wrapper;
	
}
@property (retain) KeychainItemWrapper *wrapper;
@end
