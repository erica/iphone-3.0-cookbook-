#import "CustomCell.h"

@implementation CustomCell
@synthesize button;
@synthesize primaryLabel;
@synthesize secondaryLabel;

- (IBAction) buttonPress: (UIButton *) aButton
{
	NSString *fontName = self.primaryLabel.text;
	NSArray *fonts = [UIFont fontNamesForFamilyName:fontName];
	UIAlertView *av = [[[UIAlertView alloc] initWithTitle:fontName message:[fonts componentsJoinedByString:@", "] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[av show];
}

- (void) dealloc
{
	self.button = nil;
	self.primaryLabel = nil;
	self.secondaryLabel = nil;
	[super dealloc];
}
@end
