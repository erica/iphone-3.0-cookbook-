//
//  HelloWorldAppDelegate.h
//  HelloWorld
//
//  Created by Erica Sadun on 5/19/09.
//  Copyright Up To No Good, Inc. 2009. All rights reserved.
//

@interface HelloWorldAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

