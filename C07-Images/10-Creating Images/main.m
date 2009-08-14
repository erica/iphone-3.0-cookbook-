/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#import "UIView-SubviewGeometry.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	NSInteger count;
}
@end

@implementation TestBedViewController
#define	SIDE_LENGTH	60.0f
#define INSET_AMT	2.0f
// Draw centered text into the context
void centerText(CGContextRef context, NSString *fontname, float textsize, NSString *text, CGPoint point, UIColor *color)
{
	CGContextSaveGState(context);
	CGContextSelectFont(context, [fontname UTF8String], textsize, kCGEncodingMacRoman);
	
	// Retrieve the text width without actually drawing anything
	CGContextSaveGState(context);
	CGContextSetTextDrawingMode(context, kCGTextInvisible);
	CGContextShowTextAtPoint(context, 0.0f, 0.0f, [text UTF8String], text.length);
	CGPoint endpoint = CGContextGetTextPosition(context);
	CGContextRestoreGState(context);
	
	// Query for size to recover height. Width is less reliable
	CGSize stringSize = [text sizeWithFont:[UIFont fontWithName:fontname size:textsize]];
	
	// Draw the text
	[color setFill];
	CGContextSetShouldAntialias(context, true);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextSetTextMatrix (context, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
	CGContextShowTextAtPoint(context, point.x - endpoint.x / 2.0f, point.y + stringSize.height / 4.0f, [text UTF8String], text.length); 
	CGContextRestoreGState(context);
}

- (UIImage *) createImageWithColor: (UIColor *) color
{
	UIGraphicsBeginImageContext(CGSizeMake(SIDE_LENGTH, SIDE_LENGTH));
	CGContextRef context = UIGraphicsGetCurrentContext();

	// Create a filled ellipse
	[color setFill];
	CGContextAddEllipseInRect(context, CGRectMake(0.0f, 0.0f, SIDE_LENGTH, SIDE_LENGTH));
	CGContextFillPath(context);
	
	// Label with a number
	[[UIColor whiteColor] setFill];
	NSString *numstring = [NSString stringWithFormat:@"%d", count++];
	centerText(context, @"Georgia", 18.0f, numstring, CGPointMake(SIDE_LENGTH / 2.0f, SIDE_LENGTH / 2.0f), [UIColor whiteColor]);
	
	// Outline the circle
	CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
	CGContextAddEllipseInRect(context, CGRectMake(INSET_AMT, INSET_AMT, SIDE_LENGTH - 2.0f * INSET_AMT, SIDE_LENGTH - 2.0f * INSET_AMT));
	CGContextStrokePath(context);

	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

// Random color level, limited to 128 to better contrast with white text
#define RANDLEVEL	((random() % 128) / 256.0f)

- (void) add: (id) sender
{
	UIColor *color = [UIColor colorWithRed:RANDLEVEL green:RANDLEVEL blue:RANDLEVEL alpha:1.0f];
	UIImage *newimage = [self createImageWithColor:color];
	UIImageView *newview = [[UIImageView alloc] initWithImage:newimage];
	newview.center = [newview randomCenterInView:[self.view viewWithTag:101] withInset:0];
	[[self.view viewWithTag:101] addSubview:newview];
	[newview release];
}

- (void) viewDidLoad
{
	srandom(time(0));
	count = 1;
	
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Add", @selector(add:));
	
	UIView *outerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 240.0f, 240.0f)];
	outerView.center = CGPointMake(160.0f, 140.0f);
	outerView.backgroundColor = [UIColor lightGrayColor];
	outerView.tag = 101;
	[self.view addSubview:outerView];
	[outerView release];
}
@end

@interface TestBedAppDelegate : NSObject <UIApplicationDelegate>
@end

@implementation TestBedAppDelegate
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[[TestBedViewController alloc] init]];
	[window addSubview:nav.view];
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
