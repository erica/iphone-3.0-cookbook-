
/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#ifdef _USE_OS_3_OR_LATER
#import <MapKit/MapKit.h>
#endif

@interface UIView (TagExtensions)
- (UIAlertView *) alertViewWithTag: (NSInteger) aTag;
- (UIActionSheet *) actionSheetWithTag: (NSInteger) aTag;
- (UITableView *) tableViewWithTag: (NSInteger) aTag;
- (UITableViewCell *) tableViewCellWithTag: (NSInteger) aTag;
- (UIImageView *) imageViewWithTag: (NSInteger) aTag;
- (UIWebView *) webViewWithTag: (NSInteger) aTag;
- (UITextView *) textViewWithTag: (NSInteger) aTag;
- (UIScrollView *) scrollViewWithTag: (NSInteger) aTag;
- (UIPickerView *) pickerViewWithTag: (NSInteger) aTag;
- (UIDatePicker *) datePickerWithTag: (NSInteger) aTag;
- (UISegmentedControl *) segmentedControlWithTag: (NSInteger) aTag;
- (UILabel *) labelWithTag: (NSInteger) aTag;
- (UIButton *) buttonWithTag: (NSInteger) aTag;
- (UITextField *) textFieldWithTag: (NSInteger) aTag;
- (UISwitch *) switchWithTag: (NSInteger) aTag;
- (UISlider *) sliderWithTag: (NSInteger) aTag;
- (UIProgressView *) progressViewWithTag: (NSInteger) aTag;
- (UIActivityIndicatorView *) activityIndicatorViewWithTag: (NSInteger) aTag;
- (UIPageControl *) pageControlWithTag: (NSInteger) aTag;
- (UIWindow *) windowWithTag: (NSInteger) aTag;
- (UISearchBar *) searchBarWithTag: (NSInteger) aTag;
- (UINavigationBar *) navigationBarWithTag: (NSInteger) aTag;
- (UIToolbar *) toolbarWithTag: (NSInteger) aTag;
- (UITabBar *) tabBarWithTag: (NSInteger) aTag;
#ifdef _USE_OS_3_OR_LATER
- (MKMapView *) mapViewWithTag: (NSInteger) aTag;
#endif
@end

