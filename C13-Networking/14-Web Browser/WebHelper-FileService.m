/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "WebHelper-FileService.h"


@implementation WebHelper (FileService)
// Return a CSS string based (very loosely) on the iui css
- (NSString *) css
{
	return @"<style>/* based on iui.css (c) 2007 by iUI Project Members */ body {     margin: 0;     font-family: Helvetica;     background: #FFFFFF;     color: #000000;     overflow-x: hidden;     -webkit-user-select: none;     -webkit-text-size-adjust: none; }  body > *:not(.toolbar) {     display: none;     position: absolute;     margin: 0;     padding: 0;     left: 0;     top: 45px;     width: 100%;     min-height: 372px; }  body > *[selected=\"true\"] {     display: block; }  a[selected], a:active {     background-color: #194fdb !important;     background-repeat: no-repeat, repeat-x;     background-position: right center, left top;     color: #FFFFFF !important; }  body > .toolbar {     box-sizing: border-box;     -moz-box-sizing: border-box;     -webkit-box-sizing: border-box;     border-bottom: 1px solid #2d3642;     border-top: 1px solid #6d84a2;     padding: 10px;     height: 45px;     background: #6d84a2 repeat-x; }  .toolbar > h1 {     position: absolute;     overflow: hidden;     font-size: 20px;     text-align: center;     font-weight: bold;     text-shadow: rgba(0, 0, 0, 0.4) 0px -1px 0;     text-overflow: ellipsis;     white-space: nowrap;     color: #FFFFFF;      margin: 1px 0 0 -120px;     left: 50%;     width: 240px;     height: 45px; }  body > ul > li {     position: relative;     margin: 0;     border-bottom: 1px solid #E0E0E0;     padding: 8px 0 8px 10px;     font-size: 20px;     font-weight: bold;     list-style: none; }  body > ul > li > a {      margin: -8px 0 -8px -10px;     padding: 8px 32px 8px 10px;     text-decoration: none;     color: inherit; }  a[target=\"_replace\"] {     box-sizing: border-box;     -webkit-box-sizing: border-box;     padding-top: 25px;     padding-bottom: 25px;     font-size: 18px;     color: cornflowerblue;     background-color: #FFFFFF;     background-image: none; }  body > .dialog {     top: 0;     width: 100%;     min-height: 417px;     z-index: 2;     background: rgba(0, 0, 0, 0.8);     padding: 0;     text-align: right; }  .dialog > fieldset {     box-sizing: border-box;     -webkit-box-sizing: border-box;     width: 100%;     margin: 0;     border: none;     border-top: 1px solid #6d84a2;     padding: 10px 6px;     background: #7388a5 repeat-x; }  .dialog > fieldset > h1 {     margin: 0 10px 0 10px;     padding: 0;     font-size: 20px;     font-weight: bold;     color: #FFFFFF;     text-shadow: rgba(0, 0, 0, 0.4) 0px -1px 0;     text-align: center; }  .dialog > fieldset > label {     position: absolute;     margin: 16px 0 0 6px;     font-size: 14px;     color: #999999; }  p {     font-family: Helvetica;     background: #FFFFFF;     color: #000000;     padding:15px;     font-size: 20px;     margin-left: 15%;     margin-right: 15%;     text-align: center; }  </style>";
}

- (NSString *) createindex
{
	NSMutableString *outdata = [NSMutableString string];
	
	[outdata appendString:@"<html>"];
	[outdata appendFormat:@"<head><title>%@</title>\n", cwd];
	[outdata appendString:@"<meta name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>"];
	[outdata appendString:[self css]];
	[outdata appendString:@"<script type=\"application/x-javascript\">"];
	[outdata appendString:@"window.onload = function() { setTimeout(function() {window.scrollTo(0,1);), 100); }"];
	[outdata appendString:@"</script>"];
	[outdata appendString:@"</head><body>"];
	
	[outdata appendFormat:@"<div class=\"toolbar\">	<h1 id=\"pageTitle\">%@</h1>	<a id=\"backButton\" class=\"button\" href=\"#\"></a>    </div>", [cwd lastPathComponent]];
	[outdata appendString:@"<ul id=\"home\" title=\"Files\" selected=\"true\">"];
	
	if (![self.cwd isEqualToString:@"/"])
	{
		NSString *nwd = [self.cwd stringByDeletingLastPathComponent];
		if (![nwd isEqualToString:@"/"])
			[outdata appendFormat:@"<li><a href=\"%@/\">Parent Directory/</a></li>\n", nwd];
	}
	
	// Read in the files
	NSString *wd = self.cwd;
	for (NSString *fname in [[NSFileManager defaultManager] directoryContentsAtPath:wd])
	{
		BOOL isDir;
		NSString *cpath = [wd stringByAppendingPathComponent:fname];
		[[NSFileManager defaultManager] fileExistsAtPath:cpath isDirectory:&isDir];
		[outdata appendFormat:@"<li><a href=\"%@%@\">%@%@</a></li>\n", 
		 cpath, isDir ? @"/" : @"", fname, isDir ? @"/" : @""];
	}
	[outdata appendString:@"</ul>"];
	[outdata appendString:@"</body></html>\n"];
	return outdata;
}

- (void) produceError: (NSString *) errorString forFD: (int) fd
{
	NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
	write (fd, [outcontent UTF8String], [outcontent length]);
	
	NSMutableString *outdata = [NSMutableString string];
	[outdata appendString:@"<html>"];
	[outdata appendString:@"<head><title>Error</title>\n"];
	[outdata appendString:@"<meta name=\"viewport\" content=\"width=320; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;\"/>"];
	[outdata appendString:[self css]];
	[outdata appendString:@"</head><body>"];
	[outdata appendString:@"<div class=\"toolbar\">	<h1 id=\"pageTitle\">Error</h1>	<a id=\"backButton\" class=\"button\" href=\"#\"></a>    </div>"];
	[outdata appendFormat:@"<p id=\"ErrorPara\" selected=\"true\"><br />%@<br /><br />Return to <a  href=\"upload.html\">upload page</a> or <a href=\"/\">Main browser</a></p>", errorString];
	[outdata appendString:@"</body></html>\n"];
	write (fd, [outdata UTF8String], [outdata length]);
	close(fd);
}

- (void) handleWebRequest: (int) fd
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	static char buffer[BUFSIZE+1];
	
	int len = read(fd, buffer, BUFSIZE); 	
	buffer[len] = '\0';
	
	NSString *request = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
	NSArray *reqs = [request componentsSeparatedByString:@"\n"];
	NSString *getreq = [[reqs objectAtIndex:0] substringFromIndex:4];
	NSRange range = [getreq rangeOfString:@"HTTP/"];
	if (range.location == NSNotFound)
	{
		printf("Error: GET request was improperly formed\n");
		close(fd);
		return;
	}
	
	NSString *filereq = [[getreq substringToIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	if ([filereq isEqualToString:@"/"]) 
	{
		self.cwd = filereq;
		NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
		write(fd, [outcontent UTF8String], [outcontent length]);
		
		NSString *outdata = [self createindex];
		write(fd, [outdata UTF8String], [outdata length]);
		close(fd);
		return;
	}
	
	filereq = [filereq stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	// Primary index.html
	if ([filereq hasSuffix:@"/"]) 
	{
		self.cwd = filereq;
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:filereq])
		{
			printf("Error: folder not found.\n");
			[self produceError:@"Requested folder was not found." forFD:fd];
			return;
		}
		
		NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
		write(fd, [outcontent UTF8String], [outcontent length]);
		
		NSString *outdata = [self createindex];
		write(fd, [outdata UTF8String], [outdata length]);
		close(fd);
		return;
	}
	
	NSString *mime = [MIMEHelper mimeForExt:[filereq pathExtension]];
	if (!mime)
	{
		printf("Error recovering mime type.\n");
		[self produceError:@"Sorry. This file type is not supported." forFD:fd];
		return;
	}
	
	// Output the file
	NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", mime];
	write (fd, [outcontent UTF8String], [outcontent length]);
	NSData *data = [NSData dataWithContentsOfFile:filereq];
	if (!data)
	{
		printf("Error: file not found.\n");
		[self produceError:@"File was not found. Please check the requested path and try again." forFD:fd];
		return;
	}
	printf("Writing %d bytes from file\n", [data length]);
	write(fd, [data bytes], [data length]);
	close(fd);
	
	[pool release];
}	
@end
