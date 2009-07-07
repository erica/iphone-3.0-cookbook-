//
//  HelloWorldAppDelegate.m
//  HelloWorld
//
//  Created by Erica Sadun on 4/24/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "HelloWorldAppDelegate.h"
#import "HelloWorldViewController.h"

@implementation HelloWorldAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
