/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "WebHelper.h"
#import "UIDevice-Reachability.h"

#define showAlert(format, ...) myShowAlert(__LINE__, (char *)__FUNCTION__, format, ##__VA_ARGS__)
#define DO_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];

// Simple Alert Utility
void myShowAlert(int line, char *functname, id formatstring,...)
{
	va_list arglist;
	if (!formatstring) return;
	va_start(arglist, formatstring);
	id outstring = [[[NSString alloc] initWithFormat:formatstring arguments:arglist] autorelease];
	va_end(arglist);
	
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:outstring message:nil delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil] autorelease];
	[av show];
}

@implementation WebHelper
@synthesize cwd;
@synthesize isServing;
@synthesize delegate;
@synthesize chosenPort;

static WebHelper *sharedInstance = nil;

+ (WebHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}

- (NSString *) getRequest: (int) fd
{
	static char buffer[BUFSIZE+1];
	int len = read(fd, buffer, BUFSIZE); 	
	buffer[len] = '\0';
	return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

// Serve files to GET requests
- (void) handleWebRequest:(int) fd
{
	// recover request
	NSString *request = [self getRequest:fd];
	
	// Create a category and implement this meaningfully
	NSMutableString *outcontent = [NSMutableString string];
	[outcontent appendString:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
	[outcontent appendString:@"<html><h1>iPhone Developer's Cookbook</h1><h3>Notice</h3>"];
	[outcontent appendString:@"<p>The core WebHelper class is not meant for deployment in its native state.  "];
	[outcontent appendString:@"Please implement a category that adds a response for the following request:</p>"];
	[outcontent appendFormat:@"<pre>%@</pre></html>", request];
	write (fd, [outcontent UTF8String], [outcontent length]);
	close(fd);
}

// Listen for external requests
- (void) listenForRequests
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	static struct	sockaddr_in cli_addr; 
	socklen_t		length = sizeof(cli_addr);
	
	while (1 > 0) {
		if (!self.isServing) return;

		if ((socketfd = accept(listenfd, (struct sockaddr *)&cli_addr, &length)) < 0)
		{
			self.isServing = NO;
			DO_CALLBACK(serviceWasLost, nil);
			return;
		}
		
		[self handleWebRequest:socketfd];
	}
	
	[pool release];
}

// Begin serving data -- this is a private method called by startService
- (void) startServer
{
	static struct	sockaddr_in serv_addr;
	
	// Set up socket
	if((listenfd = socket(AF_INET, SOCK_STREAM,0)) < 0)	
	{
		self.isServing = NO;
		DO_CALLBACK(serviceCouldNotBeEstablished, nil);
		return;
	}
	
    // Serve to a random port
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	serv_addr.sin_port = 0;
	
	// Bind
	if(bind(listenfd, (struct sockaddr *)&serv_addr,sizeof(serv_addr)) <0)	
	{
		self.isServing = NO;
		DO_CALLBACK(serviceCouldNotBeEstablished, nil);
		return;
	}
	
	// Find out what port number was chosen.
	int namelen = sizeof(serv_addr);
	if (getsockname(listenfd, (struct sockaddr *)&serv_addr, (void *) &namelen) < 0) {
		close(listenfd);
		self.isServing = NO;
		DO_CALLBACK(serviceCouldNotBeEstablished, nil);
		return;
	}
	
	chosenPort = ntohs(serv_addr.sin_port);
	
	// Listen
	if(listen(listenfd, 64) < 0)	
	{
		self.isServing = NO;
		DO_CALLBACK(serviceCouldNotBeEstablished, nil);
		return;
	} 
	
	DO_CALLBACK(serviceWasEstablished, nil);
	[NSThread detachNewThreadSelector:@selector(listenForRequests) toTarget:self withObject:NULL];
}

- (void) startService
{
	if (self.isServing) return;
	if (![UIDevice  networkAvailable])
	{
		showAlert(@"You are not connected to the network. Please do so before running this application.");
		return;
	}
	[self startServer];
	self.isServing = YES;
}	
@end
