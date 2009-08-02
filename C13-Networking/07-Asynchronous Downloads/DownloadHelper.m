/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "DownloadHelper.h"

#define DELEGATE_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];
#define NUMBER(X) [NSNumber numberWithFloat:X]

static DownloadHelper *sharedInstance = nil;

@interface DownloadOperation : NSOperation
@end

@implementation DownloadOperation
- (void) main
{
	NSURL *url = [NSURL URLWithString:sharedInstance.urlString];
	if (!url)
	{
		NSString *reason = [NSString stringWithFormat:@"Could not create URL from string %@", sharedInstance.urlString];
		DELEGATE_CALLBACK(dataDownloadFailed:, reason);
		return;
	}
	
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
	if (!theRequest)
	{
		NSString *reason = [NSString stringWithFormat:@"Could not create URL request from string %@", sharedInstance.urlString];
		DELEGATE_CALLBACK(dataDownloadFailed:, reason);
		return;
	}
	
	NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:sharedInstance];
	if (!theConnection)
	{
		NSString *reason = [NSString stringWithFormat:@"URL connection failed for string %@", sharedInstance.urlString];
		DELEGATE_CALLBACK(dataDownloadFailed:, reason);
		return;
	}
	
	// Create the new data object
	sharedInstance.data = [NSMutableData data];
	sharedInstance.response = nil;
	
	// Run modal
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:24 * 60 * 60]];
}
@end


@implementation DownloadHelper
@synthesize response;
@synthesize data;
@synthesize delegate;
@synthesize urlString;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
	// store the response information
	sharedInstance.response = aResponse;
	
	// Check for bad connection
	if ([aResponse expectedContentLength] < 0)
	{
		NSString *reason = [NSString stringWithFormat:@"Invalid URL [%@]", sharedInstance.urlString];
		DELEGATE_CALLBACK(dataDownloadFailed:, reason);
		[connection cancel];
		CFRunLoopStop(CFRunLoopGetCurrent());
	}
	
	if ([aResponse suggestedFilename])
		DELEGATE_CALLBACK(didReceiveFilename:, [aResponse suggestedFilename]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
	// append the new data and update the delegate
	[sharedInstance.data appendData:theData];
	if (sharedInstance.response)
	{
		float expectedLength = [sharedInstance.response expectedContentLength];
		float currentLength = sharedInstance.data.length;
		float percent = currentLength / expectedLength;
		DELEGATE_CALLBACK(dataDownloadAtPercent:, NUMBER(percent));
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// finished downloading the data, cleaning up
	sharedInstance.response = nil;
	
	// Delegate is responsible for releasing data
	DELEGATE_CALLBACK(didReceiveData:, sharedInstance.data);
	if (!sharedInstance.delegate) sharedInstance.data = nil;
	CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error: Failed connection, %@", [error localizedDescription]);
	DELEGATE_CALLBACK(dataDownloadFailed:, @"Failed Connection");
	CFRunLoopStop(CFRunLoopGetCurrent());
}

+ (DownloadHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

+ (void) download:(NSString *) aURLString
{
	sharedInstance.urlString = aURLString;
	NSOperation *operation = [[[DownloadOperation alloc] init] autorelease];
	[operation start];
}
@end
