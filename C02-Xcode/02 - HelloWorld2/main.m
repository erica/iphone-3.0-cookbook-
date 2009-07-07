#import <UIKit/UIKit.h>

@interface HelloWorldViewController : UIViewController
@end

@implementation HelloWorldViewController
- (void)loadView
{
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	contentView.backgroundColor = [UIColor lightGrayColor];
	
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 30.0f)];
    label.text = @"Hello World";
    label.center = contentView.center;
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;

    [contentView addSubview:label];
    [label release];
	
	self.view = contentView;
    [contentView release];
	
	// For testing the console pane
	NSLog(@"Hello World!");
}
@end

@interface HelloWorldAppDelegate : NSObject <UIApplicationDelegate>
{
}
@end

@implementation HelloWorldAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	// Technically these leak. But dealloc is never called on the application delegate
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	HelloWorldViewController *hwvc = [[HelloWorldViewController alloc] init];
	[window addSubview:hwvc.view];
	[window makeKeyAndVisible];
}
@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"HelloWorldAppDelegate");
	[pool release];
	return retVal;
}
