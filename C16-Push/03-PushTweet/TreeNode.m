//
//  TreeNode.m
//  Created by Erica Sadun on 4/6/09.
//

#import "TreeNode.h"

@implementation TreeNode
@synthesize parent;
@synthesize children;
@synthesize key;
@synthesize leafvalue;

#pragma mark Create and Initialize TreeNodes
- (TreeNode *) init
{
	if (self = [super init]) 
	{
		key = nil;
		leafvalue = nil;
		parent = nil;
		children = nil;
	}
	return self;
}

+ (TreeNode *) treeNode
{
	return [[[self alloc] init] autorelease];
}


#pragma mark TreeNode type routines

// Determine whether the node is a leaf or a branch
- (BOOL) isLeaf
{
	return (leafvalue != nil);
}

#pragma mark TreeNode data recovery routines

// Return an array of child keys. No recursion
- (NSArray *) keys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in children) [results addObject:[node key]];
	return results;
}

// Return an array of child keys with depth-first recursion.
- (NSArray *) allKeys
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in children) 
	{
		[results addObject:[node key]];
		[results addObjectsFromArray:[node allKeys]];
	}
	return results;
}

- (NSArray *) uniqKeys
{
	NSArray *keys = [[self keys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray *array = [NSMutableArray array];
	for (id object in keys)
		if (![[array lastObject] isEqualToString:object]) [array addObject:object];
	return array;
}

- (NSArray *) allUniqKeys
{
	NSArray *keys = [[self allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	NSMutableArray *array = [NSMutableArray array];
	for (id object in keys)
		if (![[array lastObject] isEqualToString:object]) [array addObject:object];
	return array;
}

// Return an array of child leaves. No recursion
- (NSArray *) leaves
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in children) if ([node leafvalue]) [results addObject:[node leafvalue]];
	return results;
}

// Return an array of child leaves with depth-first recursion.
- (NSArray *) allLeaves
{
	NSMutableArray *results = [NSMutableArray array];
	for (TreeNode *node in children) 
	{
		if ([node leafvalue]) [results addObject:[node leafvalue]];
		[results addObjectsFromArray:[node allLeaves]];
	}
	return results;
}

#pragma mark TreeNode search and retrieve routines

// Return the first child that matches the key, searching recursively breadth first
- (TreeNode *) objectForKey: (NSString *) aKey
{
	TreeNode *result = nil;
	for (TreeNode *node in children) 
		if ([[node key] isEqualToString: aKey])
		{
			result = node;
			break;
		}
	if (result) return result;
	for (TreeNode *node in children)
	{
		result = [node objectForKey:aKey];
		if (result) break;
	}
	return result;
}

// Return the first leaf whose key is a match, searching recursively breadth first
- (NSString *) leafForKey: (NSString *) aKey
{
	NSString *result = nil;
	for (TreeNode *node in children) 
		if ([[node key] isEqualToString: aKey]) 
			if ([node leafvalue]) 
			{
				result = [node leafvalue];
				break;
			}
	if (result) return result;
	for (TreeNode *node in children)
	{
		result = [node leafForKey:aKey];
		if (result) break;
	}
	return result;
}

// Return all children that match the key, including recursive depth first search.
- (NSMutableArray *) objectsForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in children) 
	{
		if ([[node key] isEqualToString: aKey]) [result addObject:node];
		[result addObjectsFromArray:[node objectsForKey:aKey]];
	}
	return result;
}

// Return all leaves that match the key, including recursive depth first search.
- (NSMutableArray *) leavesForKey: (NSString *) aKey
{
	NSMutableArray *result = [NSMutableArray array];
	for (TreeNode *node in children) 
	{
		if ([[node key] isEqualToString: aKey]) 
			if ([node leafvalue])
				[result addObject:[node leafvalue]];
		[result addObjectsFromArray:[node leavesForKey:aKey]];
	}
	return result;
}

// Follow a key path that matches each first found branch, returning object
- (TreeNode *) objectForKeys: (NSArray *) keys
{
	if ([keys count] == 0) return self;
	
	NSMutableArray *nextArray = [NSMutableArray arrayWithArray:keys];
	[nextArray removeObjectAtIndex:0];
	
	for (TreeNode *node in children)
	{
		if ([[node key] isEqualToString:[keys objectAtIndex:0]])
			return [node objectForKeys:nextArray];
	}
	
	return nil;
}

// Follow a key path that matches each first found branch, returning leaf
- (NSString *) leafForKeys: (NSArray *) keys
{
	if ([keys count] == 0)
	{
		if ([self leafvalue])
			return [self leafvalue];
		else 
			return nil;
	}
	
	NSMutableArray *nextArray = [NSMutableArray arrayWithArray:keys];
	[nextArray removeObjectAtIndex:0];
	
	for (TreeNode *node in children)
	{
		if ([[node key] isEqualToString:[keys objectAtIndex:0]])
			return [node leafForKeys:nextArray];
	}
	
	return nil;
}

// Print out the tree
- (void) dumpAtIndent: (int) indent
{
	for (int i = 0; i < indent; i++) printf("--");
	
	printf("[%2d] Key: %s ", indent, [key UTF8String]);
	if (leafvalue) printf("(%s)", [leafvalue UTF8String]);
	printf("\n");
	
	for (TreeNode *node in children) [node dumpAtIndent:indent + 1];
}

- (void) dump
{
	[self dumpAtIndent:0];
}

// When you're sure you're the parent of all leaves, transform to a dictionary
- (NSMutableDictionary *) dictionaryForChildren
{
	NSMutableDictionary *results = [NSMutableDictionary dictionary];
	
	for (TreeNode *node in children)
		if ([node isLeaf]) [results setObject:[node leafvalue] forKey:[node key]];
	
	return results;
}

- (void) dealloc
{
	self.parent = nil;
	self.children = nil;
	self.key = nil;
	self.leafvalue = nil;
	
	[super dealloc];
}

@end