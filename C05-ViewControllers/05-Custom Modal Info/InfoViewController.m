#import "InfoViewController.h"

@implementation InfoViewController
- (IBAction) doneReading
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}
@end
