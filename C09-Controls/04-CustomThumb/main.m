/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@interface TestBedViewController : UIViewController
{
	float previousValue;
	UIImage *simpleThumbImage;
	CGRect baseFrame;
	CGRect thumbFrame;
}
@end

@implementation TestBedViewController
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

// Create a thumb image using a grayscale/numeric level
- (UIImage *) createImageWithLevel: (float) aLevel
{
	UIGraphicsBeginImageContext(CGSizeMake(40.0f, 100.0f));
	CGContextRef context = UIGraphicsGetCurrentContext();

	float INSET_AMT = 1.5f;

	// Create a filled rect for the thumb
	[[UIColor darkGrayColor] setFill];
	CGContextAddRect(context, CGRectMake(INSET_AMT, 40.0f + INSET_AMT, 40.0f - 2.0f * INSET_AMT, 20.0f - 2.0f * INSET_AMT));
	CGContextFillPath(context);
	
	// Outline the thumb
	[[UIColor whiteColor] setStroke];
	CGContextSetLineWidth(context, 2.0f);	
	CGContextAddRect(context, CGRectMake(2.0f * INSET_AMT, 40.0f + 2.0f * INSET_AMT, 40.0f - 4.0f * INSET_AMT, 20.0f - 4.0f * INSET_AMT));
	CGContextStrokePath(context);

	// Create a filled ellipse for the indicator
	[[UIColor colorWithWhite:aLevel alpha:1.0f] setFill];
	CGContextAddEllipseInRect(context, CGRectMake(0.0f, 0.0f, 40.0f, 40.0f));
	CGContextFillPath(context);
	
	// Label with a number
	NSString *numstring = [NSString stringWithFormat:@"%0.1f", aLevel];
	UIColor *textColor = (aLevel > 0.5f) ? [UIColor blackColor] : [UIColor whiteColor];
	centerText(context, @"Georgia", 20.0f, numstring, CGPointMake(20.0f, 20.0f), textColor);
	
	// Outline the indicator circle
	[[UIColor grayColor] setStroke];
	CGContextSetLineWidth(context, 3.0f);	
	CGContextAddEllipseInRect(context, CGRectMake(INSET_AMT, INSET_AMT, 40.0f - 2.0f * INSET_AMT, 40.0f - 2.0f * INSET_AMT));
	CGContextStrokePath(context);
	
	// Build and return the image
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

// Return a base thumb image without the bubble
UIImage *createSimpleThumb()
{
	float INSET_AMT = 1.5f;
	UIGraphicsBeginImageContext(CGSizeMake(40.0f, 100.0f));
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// Create a filled rect for the thumb
	[[UIColor darkGrayColor] setFill];
	CGContextAddRect(context, CGRectMake(INSET_AMT, 40.0f + INSET_AMT, 40.0f - 2.0f * INSET_AMT, 20.0f - 2.0f * INSET_AMT));
	CGContextFillPath(context);
	
	// Outline the thumb
	[[UIColor whiteColor] setStroke];
	CGContextSetLineWidth(context, 2.0f);	
	CGContextAddRect(context, CGRectMake(2.0f * INSET_AMT, 40.0f + 2.0f * INSET_AMT, 40.0f - 4.0f * INSET_AMT, 20.0f - 4.0f * INSET_AMT));
	CGContextStrokePath(context);
	
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

// Update the thumb images as needed
- (void) updateThumb: (UISlider *) aSlider
{
	// Only update the thumb when registering significant changes, i.e. 10%
	if ((aSlider.value < 0.98) && (ABS(aSlider.value - previousValue) < 0.1f)) return;
	
	// create a new custom thumb image and use it for the highlighted state
	UIImage *customimg = [self createImageWithLevel:aSlider.value];
	[aSlider setThumbImage: simpleThumbImage forState: UIControlStateNormal];
	[aSlider setThumbImage: customimg forState: UIControlStateHighlighted];
	previousValue = aSlider.value;
}

// Expand the slider to accomodate the bigger thumb
- (void) startDrag: (UISlider *) aSlider
{
	aSlider.frame = thumbFrame;
	aSlider.center = CGPointMake(160.0f, 140.0f);
}

// At release, shrink the frame back to normal
- (void) endDrag: (UISlider *) aSlider
{
	aSlider.frame = baseFrame;
	aSlider.center = CGPointMake(160.0f, 140.0f);
}

- (void) viewDidLoad
{
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
	self.title = @"Custom Slider";

	// Initialize slider settigns
	previousValue = -99.0f;
	simpleThumbImage = [createSimpleThumb() retain];
	thumbFrame = CGRectMake(0.0f, 0.0f, 280.0f, 100.0f);
	baseFrame = CGRectMake(0.0f, 0.0f, 280.0f, 40.0f);	
	
	// Create slider
	UISlider *slider = [[UISlider alloc] initWithFrame:baseFrame];
	slider.center = CGPointMake(160.0f, 140.0f);
	slider.value = 0.0f;
	
	// Create the callbacks for touch, move, and release
	[slider addTarget:self action:@selector(startDrag:) forControlEvents:UIControlEventTouchDown];
	[slider addTarget:self action:@selector(updateThumb:) forControlEvents:UIControlEventValueChanged];
	[slider addTarget:self action:@selector(endDrag:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];

	// Present the slider
	[self.view addSubview:slider];
	[self performSelector:@selector(updateThumb:) withObject:slider afterDelay:0.1f];
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
