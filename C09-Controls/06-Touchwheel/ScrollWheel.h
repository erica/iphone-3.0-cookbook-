#import <UIKit/UIKit.h>

@interface ScrollWheel : UIControl 
{
	float theta;
	float value;
}
@property(nonatomic) float theta;
@property(nonatomic) float value;
+ (id) scrollWheel;
@end
