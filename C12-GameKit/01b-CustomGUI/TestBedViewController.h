//
//  TestBedViewController.h
//  HelloWorld
//
//  Created by Erica Sadun on 11/30/09.
//  Copyright 2009 Up To No Good, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameKitHelper.h"

@interface TestBedViewController : UIViewController <GameKitHelperDataDelegate, UITextViewDelegate>
{
	IBOutlet UITextView *sendView;
	IBOutlet UITextView *receiveView;
	IBOutlet GameKitHelper *helper;
}
@end