/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "JSONHelper.h"

NSString *jsonescape(NSString *string)
{
	NSString *aString = [NSString stringWithString:string];
	aString = [aString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	aString = [aString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	aString = [aString stringByReplacingOccurrencesOfString:@"/" withString:@"\\/"];
	
	aString = [aString stringByReplacingOccurrencesOfString:@"\b" withString:@""];
	aString = [aString stringByReplacingOccurrencesOfString:@"\f" withString:@""];
	aString = [aString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	aString = [aString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	aString = [aString stringByReplacingOccurrencesOfString:@"\t" withString:@" "];

	return aString;
}

@implementation JSONHelper

+ (NSString *) jsonWithArray: (NSArray *) array
{
	NSString *results = @"[";
	
	int i = 1;
	for (id obj in array)
	{
		if ([obj isKindOfClass:[NSString class]])
		{
			results = [results stringByAppendingFormat:@"\"%@\"", obj];
		}
		else if ([obj isKindOfClass:[NSNumber class]])
		{
			results = [results stringByAppendingFormat:@"%d", [obj intValue]];
		}
		else if ([obj isKindOfClass:[NSNull class]])
		{
			results = [results stringByAppendingString:@"null"];
		}
		else if ([obj isKindOfClass:[NSArray class]])
		{
			results = [results stringByAppendingString:[JSONHelper jsonWithArray:obj]];
		}
		else if ([obj isKindOfClass:[NSDictionary class]])
		{
			results = [results stringByAppendingString:[JSONHelper jsonWithDict:obj]];
		}
		
		if (i < [array count]) results = [results stringByAppendingString:@","];
		i++;
	}
	
	results = [results stringByAppendingString:@"]"];
	return results;
}

+ (NSString *) jsonWithDict: (NSDictionary *) aDictionary
{
	if (!aDictionary) return nil;
	
	NSString *results = @"{";
	
	NSArray *keys = [aDictionary allKeys];
	int i = 1;
	
	for (NSString *key in keys)
	{
		results = [results stringByAppendingFormat:@"\"%@\":", key];
		id obj = [aDictionary objectForKey:key];
		
		if ([obj isKindOfClass:[NSString class]])
		{
			results = [results stringByAppendingFormat:@"\"%@\"", obj];
		}
		else if ([obj isKindOfClass:[NSNumber class]])
		{
			results = [results stringByAppendingFormat:@"%d", [obj intValue]];
		}
		else if ([obj isKindOfClass:[NSNull class]])
		{
			results = [results stringByAppendingString:@"null"];
		}
		else if ([obj isKindOfClass:[NSArray class]])
		{
			results = [results stringByAppendingString:[JSONHelper jsonWithArray:obj]];
		}
		else if ([obj isKindOfClass:[NSDictionary class]])
		{
			results = [results stringByAppendingString:[JSONHelper jsonWithDict:obj]];
		}
			
		if (i < [keys count]) results = [results stringByAppendingString:@","];
		i++;
	}
	
	results = [results stringByAppendingString:@"}"];
	return results;
}
@end
