#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell {
    IBOutlet UIButton *button;
    IBOutlet UILabel *primaryLabel;
    IBOutlet UILabel *secondaryLabel;
}

@property (assign) UIButton *button;
@property (assign) UILabel *primaryLabel;
@property (assign) UILabel *secondaryLabel;

- (IBAction) buttonPress: (UIButton *) aButton;
@end
