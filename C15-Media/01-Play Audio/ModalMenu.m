/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

/*
 All credit to Kenny TM. Mistakes are mine. 
 */

#import "ModalMenu.h"

@interface ModalMenuDelegate : NSObject <UIActionSheetDelegate>
{
	CFRunLoopRef currentLoop;
	NSUInteger index;
}
@end


@implementation ModalMenuDelegate

-(id) initWithRunLoop: (CFRunLoopRef)runLoop 
{
	if (self = [super init]) currentLoop = runLoop;
	return self;
}

-(void)actionSheet:(UIActionSheet *) aView clickedButtonAtIndex:(NSInteger)anIndex 
{
	index = anIndex;
	CFRunLoopStop(currentLoop);
}

- (NSUInteger) index
{
	return index;
}

@end

@implementation ModalMenu

BOOL isLandscape()
{
	return ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) || ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight);
}


// Will ignore any buttons beyond 5. Returns button number, starting with 0
+(NSUInteger) menuWithTitle: (NSString *) title view: (UIView *) aView  andButtons:(NSArray *) buttons
{
	
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();

	ModalMenuDelegate *madelegate = [[ModalMenuDelegate alloc] initWithRunLoop:currentLoop];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:madelegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];

	// Set max number of items
	int fewerthan = isLandscape() ? 8 : 8; // hard coding for this example. This is not a general use case for this class
	int count = 1;
	for (NSString *title in buttons) 
		if (count++ < fewerthan) [actionSheet addButtonWithTitle:title];
	[actionSheet showInView:aView];
	
	CFRunLoopRun();
	
	NSUInteger answer = [madelegate index];
	[actionSheet release];
	[madelegate release];
	return answer;
}

// Note: CGSize theStringSize = [left.text sizeWithFont:left.font constrainedToSize:CGSizeMake(230, 999) lineBreakMode:UILineBreakModeWordWrap]; via timmeh
// Will ignore any buttons beyond 5. Returns button number, starting with 0
+(void) presentText: (NSString *) text inView: (UIView *) aView  
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	ModalMenuDelegate *madelegate = [[ModalMenuDelegate alloc] initWithRunLoop:currentLoop];
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:text delegate:madelegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
	[actionSheet showInView:aView];
	
	CFRunLoopRun();

	[actionSheet release];
	[madelegate release];
}
@end
