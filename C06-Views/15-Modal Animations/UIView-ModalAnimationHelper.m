/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk

 Runloop credit to Kenny TM. Mistakes are mine. 
 */

#import "UIView-ModalAnimationHelper.h"

@interface UIViewDelegate : NSObject
{
	CFRunLoopRef currentLoop;
}
@end

@implementation UIViewDelegate
-(id) initWithRunLoop: (CFRunLoopRef)runLoop 
{
	if (self = [super init]) currentLoop = runLoop;
	return self;
}

-(void) animationFinished: (id) sender
{
	CFRunLoopStop(currentLoop);
}
@end

@implementation UIView (ModalAnimationHelper)
+ (void) commitModalAnimations
{
	CFRunLoopRef currentLoop = CFRunLoopGetCurrent();
	
	UIViewDelegate *uivdelegate = [[UIViewDelegate alloc] initWithRunLoop:currentLoop];
	[UIView setAnimationDelegate:uivdelegate];
	[UIView setAnimationDidStopSelector:@selector(animationFinished:)];
	[UIView commitAnimations];
	CFRunLoopRun();
	[uivdelegate release];
}
@end

