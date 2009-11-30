#import "CustomCell.h"

@implementation CustomCell
@synthesize customSwitch;
@synthesize customLabel;
@synthesize tableViewController;

- (IBAction) switchChanged: (UISwitch *) aSwitch;
{
	if (self.tableViewController)
		[self.tableViewController performSelector:@selector(updateSwitch:forItem:) withObject:aSwitch withObject:[self.customLabel text]];
}
@end
