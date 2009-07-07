#import "RootViewController.h"

@implementation RootViewController
- (IBAction) convert: (id) sender
{
	float invalue = [[field1 text] floatValue];
	float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
	[field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
	[field1 resignFirstResponder];
}
@end
