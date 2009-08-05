/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "TwitPicOperation.h"

#define NOTIFY_AND_LEAVE(X) {[self cleanup:X]; return;}
#define DATA(X)	[X dataUsingEncoding:NSUTF8StringEncoding]

// Posting constants
#define IMAGE_CONTENT @"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
#define STRING_CONTENT @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n"
#define MULTIPART @"multipart/form-data; boundary=------------0x0x0x0x0x0x0x0x"

@implementation TwitPicOperation
@synthesize wrapper;
@synthesize theImage;
@synthesize delegate;

- (void) cleanup: (NSString *) output
{
	self.theImage = nil;
	self.wrapper = nil;
	if (self.delegate && [self.delegate respondsToSelector:@selector(doneTweeting:)])
		[self.delegate doneTweeting:output];
}

- (NSData*)generateFormDataFromPostDictionary:(NSDictionary*)dict
{
    id boundary = @"------------0x0x0x0x0x0x0x0x";
    NSArray* keys = [dict allKeys];
    NSMutableData* result = [NSMutableData data];
	
    for (int i = 0; i < [keys count]; i++) 
    {
        id value = [dict valueForKey: [keys objectAtIndex:i]];
        [result appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		
		if ([value isKindOfClass:[NSData class]]) 
		{
			// handle image data
			NSString *formstring = [NSString stringWithFormat:IMAGE_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:value];
		}
		else 
		{
			// all non-image fields assumed to be strings
			NSString *formstring = [NSString stringWithFormat:STRING_CONTENT, [keys objectAtIndex:i]];
			[result appendData: DATA(formstring)];
			[result appendData:DATA(value)];
		}
		
		NSString *formstring = @"\r\n";
        [result appendData:DATA(formstring)];
    }
	
	NSString *formstring =[NSString stringWithFormat:@"--%@--\r\n", boundary];
    [result appendData:DATA(formstring)];
    return result;
}

- (void) main
{
	if (!self.theImage)
		NOTIFY_AND_LEAVE(@"Please set image before uploading.");

	// Use Twitter credentials for TwitPic
	self.wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"Twitter" accessGroup:nil];
	[self.wrapper release];

	NSString *uname = [self.wrapper objectForKey:(id)kSecAttrAccount];
	NSString *pword = [self.wrapper objectForKey:(id)kSecValueData];

	if (!uname || !pword || (!uname.length) || (!pword.length))
		NOTIFY_AND_LEAVE(@"Please enter your account credentials in the settings before tweeting.");
	
	NSMutableDictionary* post_dict = [[NSMutableDictionary alloc] init];
	[post_dict setObject:uname forKey:@"username"];
	[post_dict setObject:pword forKey:@"password"];
	[post_dict setObject:@"Posted from iTweet" forKey:@"message"];
	[post_dict setObject:UIImageJPEGRepresentation(self.theImage, 0.75f) forKey:@"media"];
	
	// Create the post data from the post dictionary
	NSData *postData = [self generateFormDataFromPostDictionary:post_dict];
	[post_dict release];
	
	// Establish the API request. Use upload vs uploadAndPost for skip tweet
    NSString *baseurl = @"http://twitpic.com/api/uploadAndPost"; 
    NSURL *url = [NSURL URLWithString:baseurl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (!urlRequest) NOTIFY_AND_LEAVE(@"Error creating the URL Request");
	
    [urlRequest setHTTPMethod: @"POST"];
	[urlRequest setValue:MULTIPART forHTTPHeaderField: @"Content-Type"];
    [urlRequest setHTTPBody:postData];
	
	// Submit & retrieve results
    NSError *error;
    NSURLResponse *response;
	NSLog(@"Contacting TwitPic....");
    NSData* result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (!result)
	{
		[self cleanup:[NSString stringWithFormat:@"Submission error: %@", [error localizedDescription]]];
		return;
	}
	
	// Return results
    NSString *outstring = [[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] autorelease];
	[self cleanup: outstring];
}
@end