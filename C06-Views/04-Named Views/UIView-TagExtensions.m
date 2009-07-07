/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIView-TagExtensions.h"

@implementation UIView (TagExtensions)
- (UIAlertView *) alertViewWithTag: (NSInteger) aTag
{
	return (UIAlertView *)[self viewWithTag:aTag];
}

- (UIActionSheet *) actionSheetWithTag: (NSInteger) aTag
{
	return (UIActionSheet *)[self viewWithTag:aTag];
}

- (UITableView *) tableViewWithTag: (NSInteger) aTag
{
	return (UITableView *)[self viewWithTag:aTag];
}

- (UITableViewCell *) tableViewCellWithTag: (NSInteger) aTag
{
	return (UITableViewCell *)[self viewWithTag:aTag];
}

- (UIImageView *) imageViewWithTag: (NSInteger) aTag
{
	return (UIImageView *)[self viewWithTag:aTag];
}

- (UIWebView *) webViewWithTag: (NSInteger) aTag
{
	return (UIWebView *)[self viewWithTag:aTag];
}

- (UITextView *) textViewWithTag: (NSInteger) aTag
{
	return (UITextView *)[self viewWithTag:aTag];
}

- (UIScrollView *) scrollViewWithTag: (NSInteger) aTag
{
	return (UIScrollView *)[self viewWithTag:aTag];
}

- (UIPickerView *) pickerViewWithTag: (NSInteger) aTag
{
	return (UIPickerView *)[self viewWithTag:aTag];
}

- (UIDatePicker *) datePickerWithTag: (NSInteger) aTag
{
	return (UIDatePicker *)[self viewWithTag:aTag];
}

- (UISegmentedControl *) segmentedControlWithTag: (NSInteger) aTag
{
	return (UISegmentedControl *)[self viewWithTag:aTag];
}

- (UILabel *) labelWithTag: (NSInteger) aTag
{
	return (UILabel *)[self viewWithTag:aTag];
}

- (UIButton *) buttonWithTag: (NSInteger) aTag
{
	return (UIButton *)[self viewWithTag:aTag];
}

- (UITextField *) textFieldWithTag: (NSInteger) aTag
{
	return (UITextField *)[self viewWithTag:aTag];
}

- (UISwitch *) switchWithTag: (NSInteger) aTag
{
	return (UISwitch *)[self viewWithTag:aTag];
}

- (UISlider *) sliderWithTag: (NSInteger) aTag
{
	return (UISlider *)[self viewWithTag:aTag];
}

- (UIProgressView *) progressViewWithTag: (NSInteger) aTag
{
	return (UIProgressView *)[self viewWithTag:aTag];
}

- (UIActivityIndicatorView *) activityIndicatorViewWithTag: (NSInteger) aTag
{
	return (UIActivityIndicatorView *)[self viewWithTag:aTag];
}

- (UIPageControl *) pageControlWithTag: (NSInteger) aTag
{
	return (UIPageControl *)[self viewWithTag:aTag];
}

- (UIWindow *) windowWithTag: (NSInteger) aTag
{
	return (UIWindow *)[self viewWithTag:aTag];
}

- (UISearchBar *) searchBarWithTag: (NSInteger) aTag
{
	return (UISearchBar *)[self viewWithTag:aTag];
}

- (UINavigationBar *) navigationBarWithTag: (NSInteger) aTag
{
	return (UINavigationBar *)[self viewWithTag:aTag];
}

- (UIToolbar *) toolbarWithTag: (NSInteger) aTag
{
	return (UIToolbar *)[self viewWithTag:aTag];
}

- (UITabBar *) tabBarWithTag: (NSInteger) aTag
{
	return (UITabBar *)[self viewWithTag:aTag];
}

#ifdef _USE_OS_3_OR_LATER
- (MKMapView *) mapViewWithTag: (NSInteger) aTag
{
	return (MKMapView *)[self viewWithTag:aTag];
}
#endif
@end