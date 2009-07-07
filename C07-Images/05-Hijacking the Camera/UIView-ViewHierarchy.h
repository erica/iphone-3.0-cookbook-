/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <UIKit/UIKit.h>

// Standalone functions
NSArray *allSubviews(UIView *aView);
NSArray *allApplicationViews();
NSArray *pathToView(UIView *aView);

// Class extensionss
@interface UIView (ViewHierarchy)
+ (NSArray *) allApplicationViews;
+ (NSArray *) viewsWithClass:(Class) aClass;
- (NSArray *) subviewsWithClass: (Class) aClass;
- (UIView *)  subviewWithClass: (Class) aClass;

@property (readonly) NSString *viewTree;
@property (readonly) NSArray *allSubviews;
@property (readonly) NSArray *viewPath;
@end

