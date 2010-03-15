//
//  TestBedViewController.h
//  HelloWorld
//
//  Created by Erica Sadun on 2/14/10.
//  Copyright 2010 Up To No Good, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestBedViewController : UIViewController
{
	IBOutlet UIImageView *imageView;
	IBOutlet UITextView *textView;
	IBOutlet UISwitch *badge;
	IBOutlet UISwitch *alert;
	IBOutlet UISwitch *sound;
}
- (IBAction) switchValueDidChange: (UISwitch *) aSwitch;
@end
