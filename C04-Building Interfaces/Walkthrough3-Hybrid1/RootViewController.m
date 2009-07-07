#import "RootViewController.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]

@implementation RootViewController
- (IBAction) convert: (id) sender
{
    float invalue = [[field1 text] floatValue];
    float outvalue = (invalue - 32.0f) * 5.0f / 9.0f;
    [field2 setText:[NSString stringWithFormat:@"%3.2f", outvalue]];
    [field1 resignFirstResponder];
}

- (void) viewDidLoad
{
	self.title = @"Converter";
	self.navigationItem.rightBarButtonItem = BARBUTTON(@"Convert", @selector(convert:));
	self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
}
@end
