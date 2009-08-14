/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "ImageHelper-Files.h"

@implementation ImageHelper
@end

NSString *documentsFolder()
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}

NSString *bundleFolder()
{
	return [[NSBundle mainBundle] bundlePath];
}

NSString *DCIMFolder()
{
	return [NSHomeDirectory() stringByAppendingPathComponent:@"../../Media/DCIM"];
}

@implementation ImageHelper (Files)

+ (NSString *) pathForItemNamed: (NSString *) fname inFolder: (NSString *) path
{
	NSString *file;
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [dirEnum nextObject]) 
		if ([[file lastPathComponent] isEqualToString:fname]) 
			return [path stringByAppendingPathComponent:file];
	return nil;
}

// Searches bundle first then documents folder
+ (UIImage *) imageNamed: (NSString *) aName
{
	NSString *path = [ImageHelper pathForItemNamed:aName inFolder:bundleFolder()];
	path = path ? path : [ImageHelper pathForItemNamed:aName inFolder:documentsFolder()];
	if (!path) return nil;
	return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *) imageFromURLString: (NSString *) urlstring
{
	NSURL *url = [NSURL URLWithString:urlstring];
	return [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
}

+ (NSArray *) DCIMImages
{
	NSString *file;
	NSMutableArray *results = [NSMutableArray array];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:DCIMFolder()];
	while (file = [dirEnum nextObject]) if ([file hasSuffix:@"JPG"]) [results addObject:file];
	return results;
}

+ (UIImage *) DCIMImageNamed: (NSString *) aName
{
	NSString *path = [ImageHelper pathForItemNamed:aName inFolder:DCIMFolder()];
	return [UIImage imageWithContentsOfFile:path];
}
@end
