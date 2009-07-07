/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "UIView-ViewHierarchy.h"


// Return an exhaustive descent of the view's subviews
NSArray *allSubviews(UIView *aView)
{
	NSArray *results = [aView subviews];
	for (UIView *eachView in [aView subviews])
	{
		NSArray *riz = allSubviews(eachView);
		if (riz) results = [results arrayByAddingObjectsFromArray:riz];
	}
	return results;
}

// Return all views throughout the application
NSArray *allApplicationViews()
{
    NSArray *results = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
	{
		NSArray *riz = allSubviews(window);
        if (riz) results = [results arrayByAddingObjectsFromArray: riz];
	}
    return results;
}

// Return an array of parent views from the window down to the view
NSArray *pathToView(UIView *aView)
{
    NSMutableArray *array = [NSMutableArray arrayWithObject:aView];
    UIView *view = aView;
    UIWindow *window = aView.window;
    while (view != window)
    {
        view = [view superview];
        [array insertObject:view atIndex:0];
    }
    return array;
}	

@implementation UIView (ViewHierarchy)

// Recursively travel down the view tree, increasing the indentation level for children
- (void) dumpView: (UIView *) aView atIndent: (int) indent into:(NSMutableString *) outstring
{
    for (int i = 0; i < indent; i++) [outstring appendString:@"--"];
	NSString *tag = (aView.tag == 0) ? @"" : [NSString stringWithFormat:@" (%d)", aView.tag];
    [outstring appendFormat:@"[%2d] %@%@\n", indent, [[aView class] description], tag];
    for (UIView *view in [aView subviews]) 
        [self dumpView:view atIndent:indent + 1 into:outstring];
}

// Start the tree recursion at level 0 with the root view
- (NSString *) viewTree
{
    NSMutableString *outstring = [[NSMutableString alloc] init];
    [self dumpView:self atIndent:0 into:outstring];
    return [outstring autorelease];
}

// Return all subviews exhaustively
- (NSArray *) allSubviews
{
    NSArray *results = [self subviews];
    for (UIView *view in [self subviews])
	{
		NSArray *riz  = [view allSubviews];
        if (riz) results = [results arrayByAddingObjectsFromArray:riz];
	}
    return results;
}

// Return a superview path from the window down to the view
- (NSArray *) viewPath
{
    NSMutableArray *results = [NSMutableArray arrayWithObject:self];
    UIView *view = self;
    UIWindow *window = self.window;
    while (view != window)
    {
        view = [view superview];
        [results insertObject:view atIndex:0];
    }
    return results;
}

// Return all views throughout the application
+ (NSArray *) allApplicationViews
{
    NSArray *results = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
	{
		NSArray *riz = window.allSubviews;
        if (riz) results = [results arrayByAddingObjectsFromArray: riz];
	}
    return results;
}

+ (NSArray *) viewsWithClass:(Class) aClass
{
	NSMutableArray *results = [NSMutableArray array];
	for (UIView *view in [UIView allApplicationViews])
		if ([view isKindOfClass:aClass]) [results addObject:view];
	return results;
}

- (NSArray *) subviewsWithClass: (Class) aClass
{
	NSMutableArray *results = [NSMutableArray array];
	for (UIView *view in self.allSubviews)
		if ([view isKindOfClass:aClass]) [results addObject:view];
	return results;
}

- (UIView *) subviewWithClass: (Class) aClass
{
	NSArray *array = [self subviewsWithClass:aClass];
	if (![array count]) return nil;
	return [array objectAtIndex:0];
}

@end

