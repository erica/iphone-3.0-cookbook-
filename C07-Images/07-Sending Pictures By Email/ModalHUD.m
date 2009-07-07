/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ModalHUD.h"

#define MODAL_HUD_UNIQUE_ID	314159265

@implementation ModalHUD
+ (void) dismiss
{
	UIAlertView *av = (UIAlertView *)[[[UIApplication sharedApplication] keyWindow] viewWithTag:MODAL_HUD_UNIQUE_ID];
	[av dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark Activity Indicator HUD Utilities
+ (void) showTitle:(NSString *) aTitle withMessage:(id)formatstring,...
{
	// just in case one is already open
	[self dismiss];

	NSString *outstring = nil;
	va_list arglist;
	if (formatstring)
	{
		va_start(arglist, formatstring);
		outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
		va_end(arglist);
		
		outstring = [outstring stringByAppendingString:@"\n\n"];
	}
	
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:aTitle message:outstring delegate:nil cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
	av.tag = MODAL_HUD_UNIQUE_ID;
	[av show];
	
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	aiv.tag = 99;
	
	// Wait for av to finish displaying
	while (CGRectEqualToRect(av.bounds, CGRectZero));

	// Add activity indicator
	int dy = outstring ? 55.0f : 45.0f;
	CGRect bounds = av.bounds;
	aiv.center = CGPointMake(bounds.size.width / 2.0f, bounds.size.height - dy);
	[aiv startAnimating];
	[av addSubview:aiv];	
	[aiv release];
}

// Workaround for ensuring the HUD appears onscreen with no blocking
+ (void) showIt:(NSString *) string
{
	[self showTitle:string withMessage:nil];
}

+ (void) showHUD:(id)formatstring,...
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	[self performSelector:@selector(showIt:) withObject:outstring afterDelay:0.1f];
}
@end
