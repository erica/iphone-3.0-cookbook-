#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    IBOutlet UIButton *button;
    IBOutlet UILabel *primaryLabel;
    IBOutlet UILabel *secondaryLabel;
}

@property (retain) UIButton *button;
@property (retain) UILabel *primaryLabel;
@property (retain) UILabel *secondaryLabel;

- (IBAction) buttonPress: (UIButton *) aButton;
@end
