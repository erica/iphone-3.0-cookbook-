/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import <Foundation/Foundation.h>

@protocol JackClient <NSObject>
- (void) musicDidPlay;
- (void) jackDidAppear;
@optional
- (void) nothingDidHappen;
@end

@interface JackInTheBox : NSObject
{
	id <JackClient> client;
}
+ (JackInTheBox *) jack;
- (void) turnTheCrank;
@property (retain)	id <JackClient> client;
@end
