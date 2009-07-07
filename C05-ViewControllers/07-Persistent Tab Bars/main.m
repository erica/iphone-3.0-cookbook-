/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "GraphicsUtilities.h"

@interface BrightnessController : UIViewController
{
	int brightness;
}
@end

@implementation BrightnessController
- (UIImage*) buildSwatch: (float) tint
{
	CGContextRef context  = [GraphicsUtilities newBitmapContextWithWidth:30 andHeight:30];
	[GraphicsUtilities addRoundedRect:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f) toContext:context withWidth:4.0f andHeight:4.0f];
	CGFloat gray[4] = {tint, tint, tint, 1.0f};
	CGContextSetFillColor(context, gray);
	CGContextFillPath(context);
	
	CGImageRef myRef = CGBitmapContextCreateImage (context);
	free(CGBitmapContextGetData(context));
	CGContextRelease(context);
	UIImage *img = [UIImage imageWithCGImage:myRef];
	CFRelease(myRef);
	return img;
}

-(BrightnessController *) initWithBrightness: (int) aBrightness
{
	self = [super init];
	brightness = aBrightness;
	self.title = [NSString stringWithFormat:@"%d%%", brightness * 10];
	[self.tabBarItem initWithTitle:self.title image:[self buildSwatch:(((float)brightness) / 10.0f)] tag:0];
	return self;
}

- (void) loadView
{
	self.view = [[[NSBundle mainBundle] loadNibNamed:@"mainview" owner:self options:nil] lastObject];
	UIView *bigSwatch = [self.view viewWithTag:101];
	bigSwatch.backgroundColor = [UIColor colorWithWhite:(brightness / 10.0f) alpha:1.0f];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate>
@end

@implementation TestBedAppDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	NSMutableArray *titles = [NSMutableArray array];
	for (UIViewController *vc in viewControllers) [titles addObject:vc.title];
	[[NSUserDefaults standardUserDefaults] setObject:titles forKey:@"tabOrder"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	NSNumber *tabNumber = [NSNumber numberWithInt:[tabBarController selectedIndex]];
	[[NSUserDefaults standardUserDefaults] setObject:tabNumber forKey:@"selectedTab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	NSMutableArray *controllers = [NSMutableArray array];
	NSArray *titles = [[NSUserDefaults standardUserDefaults] objectForKey:@"tabOrder"];
	
	if (titles)
	{
		// titles retrieved from user defaults
		for (NSString *theTitle in titles)
		{
			BrightnessController *bControl = [[BrightnessController alloc] initWithBrightness:([theTitle intValue] / 10)];
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:bControl];
			nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
			[bControl release];
			
			[controllers addObject:nav];
			[nav release];
		}
	} else {
		// generate all new controllers
		for (int i = 0; i <= 10; i++) 
		{
			BrightnessController *bControl = [[BrightnessController alloc] initWithBrightness:i];
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:bControl];
			nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
			[bControl release];
			
			[controllers addObject:nav];
			[nav release];
		}
	}		
	// Create the toolbar and add the view controllers
	UITabBarController *tbarController = [[UITabBarController alloc] init];
	tbarController.viewControllers = controllers;
	tbarController.customizableViewControllers = controllers;
	tbarController.delegate = self;
	
	NSNumber *tabNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTab"];
	if (tabNumber)
		tbarController.selectedIndex = [tabNumber intValue];
	
	// Set up the window
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window addSubview:tbarController.view];
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
