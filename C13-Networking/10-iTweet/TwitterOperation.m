/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "TwitterOperation.h"

#define NOTIFY_AND_LEAVE(X) {[self cleanup:X]; return;}
#define ENCODE(X) [(X) stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]

@implementation TwitterOperation
@synthesize wrapper;
@synthesize theText;
@synthesize delegate;

- (void) cleanup: (NSString *) output
{
	self.theText = nil;
	self.wrapper = nil;
	if (self.delegate && [self.delegate respondsToSelector:@selector(doneTweeting:)])
		[self.delegate doneTweeting:output];
}

- (void) main
{
	if (!theText || ![theText length])
		NOTIFY_AND_LEAVE(@"You cannot tweet an empty message.");

	self.wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Twitter" accessGroup:nil];
	[self.wrapper release];

	NSString *uname = [self.wrapper objectForKey:(id)kSecAttrAccount];
	NSString *pword = [self.wrapper objectForKey:(id)kSecValueData];

	if (!uname || !pword || (!uname.length) || (!pword.length))
		NOTIFY_AND_LEAVE(@"Please enter your account credentials in the settings before tweeting.");

	NSString *unpwraw = [NSString stringWithFormat:@"%@:%@", uname, pword];
	NSString *unpw = ENCODE(unpwraw);
	NSString *theTweet = ENCODE(theText);
	NSString *body = [NSString stringWithFormat:@"source=iTweet&status=%@", theTweet];
	
	// Establish the Twitter API request
	NSString *baseurl = [NSString stringWithFormat:@"http://%@@twitter.com/statuses/update.xml", unpw];
	NSURL *url = [NSURL URLWithString:baseurl];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	
	if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");

	[urlRequest setHTTPMethod: @"POST"];
	[urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	[urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:@"iTweet" forHTTPHeaderField:@"X-Twitter-Client"];
	
	NSLog(@"Contacting Twitter. This can take a minute or so...");

	NSError *error;
	NSURLResponse *response;
	NSData *tw_result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	NSString *tw_output = [NSString stringWithFormat:@"Submission error: %@", [error localizedDescription]];
	if (!tw_result) NOTIFY_AND_LEAVE(tw_output);
	
	[self cleanup:[[[NSString alloc] initWithData:tw_result encoding:NSUTF8StringEncoding] autorelease]];
}
@end