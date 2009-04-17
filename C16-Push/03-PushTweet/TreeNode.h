//
//  TreeNode.h
//  Created by Erica Sadun on 4/6/09.
//

#import <CoreFoundation/CoreFoundation.h>

@interface TreeNode : NSObject
{
	TreeNode		*parent;
	NSMutableArray	*children;
	NSString		*key;
	NSString		*leafvalue;
}
@property (nonatomic, retain) 	TreeNode		*parent;
@property (nonatomic, retain) 	NSMutableArray	*children;
@property (nonatomic, retain) 	NSString		*key;
@property (nonatomic, retain) 	NSString		*leafvalue;

+ (TreeNode *) treeNode;
- (void) dump;
- (BOOL) isLeaf;

// Keys for just the node
- (NSArray *) keys;

// Sorted, uniqed keys for the node
- (NSArray *) uniqKeys;

// All keys below node
- (NSArray *) allKeys;

// Sorted, uniqed keys below node
- (NSArray *) allUniqKeys;

// Leaves for just the node
- (NSArray *) leaves;

// All leaves below node
- (NSArray *) allLeaves;

- (TreeNode *) objectForKey: (NSString *) aKey;
- (NSString *) leafForKey: (NSString *) aKey;

- (NSMutableArray *) objectsForKey: (NSString *) aKey;
- (NSMutableArray *) leavesForKey: (NSString *) aKey;

- (TreeNode *) objectForKeys: (NSArray *) keys;
- (NSString *) leafForKeys: (NSArray *) keys;

- (NSMutableDictionary *) dictionaryForChildren;
@end
