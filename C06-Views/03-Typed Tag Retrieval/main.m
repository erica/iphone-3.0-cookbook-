#import <UIKit/UIKit.h>
#import "UIView-TagExtensions.h"

#define LABEL_TAG 101
#define SWITCH_TAG 102

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]

@interface RootViewController : UIViewController
- (IBAction)updateSwitch:(id)sender;
- (IBAction)updateTime:(id)sender;
@end

@implementation RootViewController
- (IBAction)updateSwitch:(id)sender 
{
	// toggle the switch from its current setting
	UISwitch *s = [self.view.window switchWithTag:SWITCH_TAG];
	[s setOn:!s.isOn];
}

- (IBAction)updateTime:(id)sender 
{
	// set the label to the current time
	[self.view.window labelWithTag:LABEL_TAG].text = [[NSDate date] description];
}

- (void) viewDidAppear: (BOOL) animated
{
	[self updateTime:nil];
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
}
@end

@interface HelloWorldAppDelegate : NSObject <UIApplicationDelegate>
{    
    UIWindow *window;
    UINavigationController *navigationController;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@end

@implementation HelloWorldAppDelegate
@synthesize window;
@synthesize navigationController;
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	[window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
