#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    IBOutlet UISwitch *customSwitch;
	IBOutlet UILabel *customLabel;
	UITableViewController *tableViewController;
}

@property (assign) UISwitch *customSwitch;
@property (assign) UILabel *customLabel;
@property (assign) UITableViewController *tableViewController;
- (IBAction) switchChanged: (UISwitch *) aSwitch;
@end
