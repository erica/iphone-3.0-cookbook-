#import <CoreFoundation/CoreFoundation.h>
#import "XMLParser.h"
#import "APNSHelper.h"
#import "JSONHelper.h"

#define TWEET_FILE	[NSHomeDirectory() stringByAppendingPathComponent:@".tweet"]
#define URL_STRING	@"http://search.twitter.com/search.atom?q=+ericasadun+OR+sadun++-sadunalpdag+-alpdag"
#define SHOW_TICK	NO
#define CAL_FORMAT	@"%Y-%m-%dT%H:%M:%SZ"

int main (int argc, const char * argv[]) {
	
	if (argc < 2)
	{
		printf("Usage: %s delay-in-seconds\n", argv[0]);
		exit(-1);
	} 
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Fetch certificate and device information from the current directory as set up with pushutil
	char wd[256];
	getwd(wd);
	NSString *cwd = [NSString stringWithCString:wd  encoding:NSUTF8StringEncoding];
	NSArray *contents = [[NSFileManager defaultManager] directoryContentsAtPath:cwd];
	
	NSArray *dfiles = [contents pathsMatchingExtensions:[NSArray arrayWithObject:@"devices"]];
	if (![dfiles count])
	{
		printf("Error retrieving device token\n");
		exit(-1);
	}
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[cwd stringByAppendingPathComponent:[dfiles lastObject]]];
	if (!dict || ([[dict allKeys] count] < 1))
	{
		printf("Error retrieving device token\n");
		exit(-1);
	}
	[APNSHelper sharedInstance].deviceTokenID = [dict objectForKey:[[dict allKeys] objectAtIndex:0]];
	
	NSArray *certs = [contents pathsMatchingExtensions:[NSArray arrayWithObject:@"cer"]];
	if ([certs count] < 1)
	{
		printf("Error finding SSL certificate\n");
		exit(-1);
	}
	NSString *certPath = [certs lastObject];
	NSData *dCert = [NSData dataWithContentsOfFile:certPath];
	if (!dCert)
	{
		printf("Error retrieving SSL certificate\n");
		exit(-1);
	}	
	[APNSHelper sharedInstance].certificateData = dCert;
	
	// Set up delay
	int delay = atoi(argv[1]);
	printf("Initializing with delay of %d\n", delay);
	
	// Set up dictionaries
	NSMutableDictionary *mainDict = [NSMutableDictionary dictionary];
	NSMutableDictionary *payloadDict = [NSMutableDictionary dictionary];
	NSMutableDictionary *alertDict = [NSMutableDictionary dictionary];
	
	[mainDict setObject:payloadDict forKey:@"aps"];
	[payloadDict setObject:alertDict forKey:@"alert"];
	[payloadDict setObject:@"ping1.caf" forKey:@"sound"];
	[alertDict setObject:[NSNull null] forKey:@"action-loc-key"];
	
	while (1 > 0)
	{
	
		NSAutoreleasePool *wadingpool = [[NSAutoreleasePool alloc] init];
		TreeNode *root = [[XMLParser sharedInstance] parseXMLFromURL: [NSURL URLWithString:URL_STRING]];
		TreeNode *found = [root objectForKey:@"entry"];

		if (found)
		{
			// Recover the string to tweet
			NSString *tweetString = [NSString stringWithFormat:@"%@-%@", [found leafForKey:@"name"], [found leafForKey:@"title"]];
			
			// Recover pubbed date
			NSString *dateString = [found leafForKey:@"published"];
			NSCalendarDate *date = [NSCalendarDate dateWithString:dateString calendarFormat:CAL_FORMAT];

			// Recover stored date
			NSString *prevDateString = [NSString stringWithContentsOfFile:TWEET_FILE encoding:NSUTF8StringEncoding error:nil];
			NSCalendarDate *pDate = [NSCalendarDate dateWithString:prevDateString calendarFormat:CAL_FORMAT];
			
			// Tweet only if there is either no stored date or the dates are not equal
			if (!pDate || ![pDate isEqualToDate:date])
			{
				// Update with the new tweet information
				NSLog(@"\nNew tweet from %@:\n   \"%@\"\n\n", [found leafForKey:@"name"], [found leafForKey:@"title"]);
				
				// Store the tweet time
				[dateString writeToFile:TWEET_FILE atomically:YES encoding:NSUTF8StringEncoding error:nil];
								
				// push it
				[alertDict setObject:jsonescape(tweetString) forKey:@"body"];
				[[APNSHelper sharedInstance] push:[JSONHelper jsonWithDict:mainDict]];
			}
		}

		root = nil;
		found = nil;
	
		[wadingpool drain];
		
		[NSThread sleepForTimeInterval:(double) delay];
		if (SHOW_TICK) printf("tick\n");
	}
	
	[pool drain];
    return 0;
}
