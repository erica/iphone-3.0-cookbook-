//
//  HelloWorldAppDelegate.h
//  HelloWorld
//
//  Created by Erica Sadun on 5/25/09.
//  Copyright Up To No Good, Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelloWorldAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
