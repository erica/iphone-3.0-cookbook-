//
//  XMLParser.h
//  Created by Erica Sadun on 4/6/09.
//

#import <CoreFoundation/CoreFoundation.h>
#import "TreeNode.h"

@interface XMLParser : NSObject
{
	NSMutableArray		*stack;
}

+ (XMLParser *) sharedInstance;
- (TreeNode *) parseXMLFromURL: (NSURL *) url;
@end

