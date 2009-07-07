//
//  HelloWorldAppDelegate.m
//  HelloWorld
//
//  Created by Erica Sadun on 5/19/09.
//  Copyright Up To No Good, Inc. 2009. All rights reserved.
//

#import "HelloWorldAppDelegate.h"
#import "RootViewController.h"


@implementation HelloWorldAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
	
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

