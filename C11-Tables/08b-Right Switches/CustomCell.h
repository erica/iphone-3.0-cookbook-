#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    IBOutlet UISwitch *customSwitch;
	IBOutlet UILabel *customLabel;
	UITableViewController *tableViewController;
}

@property (retain) UISwitch *customSwitch;
@property (retain) UILabel *customLabel;
@property (retain) UITableViewController *tableViewController;
- (IBAction) switchChanged: (UISwitch *) aSwitch;
@end
