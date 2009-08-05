/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>
#ifdef _USE_OS_3_OR_LATER
#import <MapKit/MapKit.h>
#endif

@interface UIView (NameExtensions)
- (NSInteger) registerName: (NSString *) aName;
- (BOOL) unregisterName: (NSString *) aName;

- (UIView *) viewNamed: (NSString *) aName;
- (UIAlertView *) alertViewNamed: (NSString *) aName;
- (UIActionSheet *) actionSheetNamed: (NSString *) aName;
- (UITableView *) tableViewNamed: (NSString *) aName;
- (UITableViewCell *) tableViewCellNamed: (NSString *) aName;
- (UIImageView *) imageViewNamed: (NSString *) aName;
- (UIWebView *) webViewNamed: (NSString *) aName;
- (UITextView *) textViewNamed: (NSString *) aName;
- (UIScrollView *) scrollViewNamed: (NSString *) aName;
- (UIPickerView *) pickerViewNamed: (NSString *) aName;
- (UIDatePicker *) datePickerNamed: (NSString *) aName;
- (UISegmentedControl *) segmentedControlNamed: (NSString *) aName;
- (UILabel *) labelNamed: (NSString *) aName;
- (UIButton *) buttonNamed: (NSString *) aName;
- (UITextField *) textFieldNamed: (NSString *) aName;
- (UISwitch *) switchNamed: (NSString *) aName;
- (UISlider *) sliderNamed: (NSString *) aName;
- (UIProgressView *) progressViewNamed: (NSString *) aName;
- (UIActivityIndicatorView *) activityIndicatorViewNamed: (NSString *) aName;
- (UIPageControl *) pageControlNamed: (NSString *) aName;
- (UIWindow *) windowNamed: (NSString *) aName;
- (UISearchBar *) searchBarNamed: (NSString *) aName;
- (UINavigationBar *) navigationBarNamed: (NSString *) aName;
- (UIToolbar *) toolbarNamed: (NSString *) aName;
- (UITabBar *) tabBarNamed: (NSString *) aName;
#ifdef _USE_OS_3_OR_LATER
- (MKMapView *) mapViewNamed: (NSString *) aName;
#endif
@end

