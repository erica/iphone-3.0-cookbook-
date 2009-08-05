/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */

#import "FTPHelper.h"

#define DELEGATE_CALLBACK(X, Y) if (sharedInstance.delegate && [sharedInstance.delegate respondsToSelector:@selector(X)]) [sharedInstance.delegate performSelector:@selector(X) withObject:Y];
#define COMPLAIN_AND_BAIL(X) {NSLog(X); return;}
#define NUMBER(X) [NSNumber numberWithFloat:X]
#define kMyBufferSize  32768

typedef struct MyStreamInfo {
	
    CFWriteStreamRef  writeStream;
    CFReadStreamRef   readStream;
    CFDictionaryRef   proxyDict;
    SInt64            fileSize;
    UInt32            totalBytesWritten;
    UInt32            leftOverByteCount;
    UInt8             buffer[kMyBufferSize];
	
} MyStreamInfo;

static const CFOptionFlags kNetworkEvents = 
kCFStreamEventOpenCompleted
| kCFStreamEventHasBytesAvailable
| kCFStreamEventEndEncountered
| kCFStreamEventCanAcceptBytes
| kCFStreamEventErrorOccurred;

static FTPHelper *sharedInstance = nil;

@implementation FTPHelper
@synthesize delegate;
@synthesize urlString;
@synthesize isBusy;
@synthesize uname;
@synthesize pword;
@synthesize fileListings;
@synthesize filePath;

#pragma mark ***** Happy Happy Apple Stuff

// MyStreamInfoCreate creates a MyStreamInfo 'object' with the specified read and write stream.
static void MyStreamInfoCreate(MyStreamInfo **info, CFReadStreamRef readStream, CFWriteStreamRef writeStream)
{
    MyStreamInfo * streamInfo;
	
    assert(info != NULL);
    assert(readStream != NULL);
    // writeStream may be NULL (this is the case for the directory list operation)
    
    streamInfo = malloc(sizeof(MyStreamInfo));
    assert(streamInfo != NULL);
    
    streamInfo->readStream        = readStream;
    streamInfo->writeStream       = writeStream;
    streamInfo->proxyDict         = NULL;           // see discussion of <rdar://problem/3745574> below
    streamInfo->fileSize          = 0;
    streamInfo->totalBytesWritten = 0;
    streamInfo->leftOverByteCount = 0;
	
    *info = streamInfo;
}

/* MyStreamInfoDestroy destroys a MyStreamInfo 'object', cleaning up any resources that it owns. */                                       
static void MyStreamInfoDestroy(MyStreamInfo * info)
{
    assert(info != NULL);
    
    if (info->readStream) {
        CFReadStreamUnscheduleFromRunLoop(info->readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        (void) CFReadStreamSetClient(info->readStream, kCFStreamEventNone, NULL, NULL);
        
        /* CFReadStreamClose terminates the stream. */
        CFReadStreamClose(info->readStream);
        CFRelease(info->readStream);
    }
	
    if (info->writeStream) {
        CFWriteStreamUnscheduleFromRunLoop(info->writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        (void) CFWriteStreamSetClient(info->writeStream, kCFStreamEventNone, NULL, NULL);
        
        /* CFWriteStreamClose terminates the stream. */
        CFWriteStreamClose(info->writeStream);
        CFRelease(info->writeStream);
    }
	
    if (info->proxyDict) {
        CFRelease(info->proxyDict);             // see discussion of <rdar://problem/3745574> below
    }
    
    free(info);
}

static void MyCFStreamSetUsernamePassword(CFTypeRef stream, CFStringRef username, CFStringRef password)
{
    Boolean success;
    assert(stream != NULL);
    assert( (username != NULL) || (password == NULL) );
    
    if (username && CFStringGetLength(username) > 0) {
		
        if (CFGetTypeID(stream) == CFReadStreamGetTypeID()) {
            success = CFReadStreamSetProperty((CFReadStreamRef)stream, kCFStreamPropertyFTPUserName, username);
            assert(success);
            if (password) {
                success = CFReadStreamSetProperty((CFReadStreamRef)stream, kCFStreamPropertyFTPPassword, password);
                assert(success);
            }
        } else if (CFGetTypeID(stream) == CFWriteStreamGetTypeID()) {
            success = CFWriteStreamSetProperty((CFWriteStreamRef)stream, kCFStreamPropertyFTPUserName, username);
            assert(success);
            if (password) {
                success = CFWriteStreamSetProperty((CFWriteStreamRef)stream, kCFStreamPropertyFTPPassword, password);
                assert(success);
            }
        } else {
            assert(false);
        }
    }
}

#pragma mark ***** List Command
static void MyDirectoryListingCallBack(CFReadStreamRef readStream, CFStreamEventType type, void * clientCallBackInfo)
{
    MyStreamInfo     *info = (MyStreamInfo *)clientCallBackInfo;
    CFIndex          bytesRead;
    CFStreamError    error;
    CFDictionaryRef  parsedDict;
    
    assert(readStream != NULL);
    assert(info       != NULL);
    assert(info->readStream == readStream);
	
    switch (type) {
			
        case kCFStreamEventOpenCompleted:
            break;
        case kCFStreamEventHasBytesAvailable:
            bytesRead = CFReadStreamRead(info->readStream, info->buffer + info->leftOverByteCount, kMyBufferSize - info->leftOverByteCount);
            if (bytesRead > 0) {
                const UInt8 *   nextByte;
                CFIndex         bytesRemaining;
                CFIndex         bytesConsumedThisTime;
				nextByte       = info->buffer;
                bytesRemaining = bytesRead + info->leftOverByteCount;
                do
                {                    
                    bytesConsumedThisTime = CFFTPCreateParsedResourceListing(NULL, nextByte, bytesRemaining, &parsedDict);
                    if (bytesConsumedThisTime > 0) {
                        if (parsedDict != NULL) {
							[[FTPHelper sharedInstance].fileListings addObject:(NSDictionary *)parsedDict];
                            CFRelease(parsedDict);
                        }
						
                        nextByte       += bytesConsumedThisTime;
                        bytesRemaining -= bytesConsumedThisTime;
						
                    } else if (bytesConsumedThisTime == 0) {
                    } else if (bytesConsumedThisTime == -1) {
                        fprintf(stderr, "CFFTPCreateParsedResourceListing parse failure\n");
                        goto exit;
                    }
					
                } while ( (bytesRemaining > 0) && (bytesConsumedThisTime > 0) );
                
                if (bytesRemaining > 0) {
                    memmove(info->buffer, nextByte, bytesRemaining);                    
                }
                info->leftOverByteCount = bytesRemaining;
            } else {
            }
            break;
        case kCFStreamEventErrorOccurred:
            error = CFReadStreamGetError(info->readStream);
            fprintf(stderr, "CFReadStreamGetError returned (%d, %ld)\n", error.domain, error.error);
			DELEGATE_CALLBACK(listingFailed, nil);
            goto exit;
        case kCFStreamEventEndEncountered:
			DELEGATE_CALLBACK(receivedListing:, sharedInstance.fileListings);
            goto exit;
        default:
            fprintf(stderr, "Received unexpected CFStream event (%d)", type);
            break;
    }
    return;
	
exit:
    MyStreamInfoDestroy(info);
    CFRunLoopStop(CFRunLoopGetCurrent());
    return;
}


static Boolean MySimpleDirectoryListing(CFStringRef urlString, CFStringRef username, CFStringRef password)
{
    CFReadStreamRef        readStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               downloadURL;
    Boolean                success = true;
    MyStreamInfo           *streamInfo;
	
    assert(urlString != NULL);
	
    downloadURL = CFURLCreateWithString(kCFAllocatorDefault, urlString, NULL);
    assert(downloadURL != NULL);
	
    /* Create an FTP read stream for downloading operation from an FTP URL. */
	for (int i = 0; i < 10; i++)
	{
		readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, downloadURL);
		if (readStream != NULL) continue;
	}
    assert(readStream != NULL);
    CFRelease(downloadURL);
	
    /* Initialize our MyStreamInfo structure, which we use to store some information about the stream. */
    MyStreamInfoCreate(&streamInfo, readStream, NULL);
    context.info = (void *)streamInfo;
	
    /* CFReadStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
    success = CFReadStreamSetClient(readStream, kNetworkEvents, MyDirectoryListingCallBack, &context);
    if (success) {
		
        /* Schedule a run loop on which the client can be notified about stream events.  The client
		 callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
		 the run loop is running. */
        CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        
        MyCFStreamSetUsernamePassword(readStream, username, password);
        // MyCFStreamSetFTPProxy(readStream, &streamInfo->proxyDict); no proxies
		
        /* CFReadStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
		 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
		 listen to the run loop source to find out when the open completes and whether it was successful. */
        success = CFReadStreamOpen(readStream);
        if (success == false) {
            fprintf(stderr, "CFReadStreamOpen failed\n");
            MyStreamInfoDestroy(streamInfo);
        }
    } else {
        fprintf(stderr, "CFReadStreamSetClient failed\n");
        MyStreamInfoDestroy(streamInfo);
    }
	
    return success;
}

#define DTTOIF(dirtype) ((dirtype) << 12)
+ (NSString *) textForDirectoryListing: (CFDictionaryRef) dictionary
{
	CFDateRef             cfModDate;
    CFNumberRef           cfType, cfMode, cfSize;
    CFStringRef           cfOwner, cfName, cfLink, cfGroup;
    char                  owner[256], group[256], name[256];
    char                  permString[12], link[1024];
    SInt64                size;
    SInt32                mode, type;
	
	NSMutableString *outstring = [NSMutableString string];
	
    assert(dictionary != NULL);
	
    /* You should not assume that the directory entry dictionary will contain all the possible keys.
	 Most of the time it will, however, depending on the FTP server, some of the keys may be missing. */
	
    cfType = CFDictionaryGetValue(dictionary, kCFFTPResourceType);
    if (cfType) {
        assert(CFGetTypeID(cfType) == CFNumberGetTypeID());
        CFNumberGetValue(cfType, kCFNumberSInt32Type, &type);
        
        cfMode = CFDictionaryGetValue(dictionary, kCFFTPResourceMode);
        if (cfMode) {
            assert(CFGetTypeID(cfMode) == CFNumberGetTypeID());
            CFNumberGetValue(cfMode, kCFNumberSInt32Type, &mode);
            
            /* Converts inode status information into a symbolic string */
            strmode(mode + DTTOIF(type), permString);
            
            [outstring appendFormat:@"%s ", permString];
        }
    }
    
    cfOwner = CFDictionaryGetValue(dictionary, kCFFTPResourceOwner);
    if (cfOwner) {
        assert(CFGetTypeID(cfOwner) == CFStringGetTypeID());
        CFStringGetCString(cfOwner, owner, sizeof(owner), kCFStringEncodingASCII);
        [outstring appendFormat:@"%9s", owner];
    }
    
    cfGroup = CFDictionaryGetValue(dictionary, kCFFTPResourceGroup);
    if (cfGroup) {
        assert(CFGetTypeID(cfGroup) == CFStringGetTypeID());
        CFStringGetCString(cfGroup, group, sizeof(group), kCFStringEncodingASCII);
        [outstring appendFormat:@"%9s", group];
    }
    
    cfSize = CFDictionaryGetValue(dictionary, kCFFTPResourceSize);
    if (cfSize) {
        assert(CFGetTypeID(cfSize) == CFNumberGetTypeID());
        CFNumberGetValue(cfSize, kCFNumberSInt64Type, &size);
        [outstring appendFormat:@"%9lld", size];
    }
    
    cfModDate = CFDictionaryGetValue(dictionary, kCFFTPResourceModDate);
    if (cfModDate) {
        CFLocaleRef           locale;
        CFDateFormatterRef    formatDate;
        CFDateFormatterRef    formatTime;
        CFStringRef           cfDate;
        CFStringRef           cfTime;
        char                  date[256];
        char                  time[256];
		
        assert(CFGetTypeID(cfModDate) == CFDateGetTypeID());
		
        locale = CFLocaleCopyCurrent();
        assert(locale != NULL);
        
        formatDate = CFDateFormatterCreate(kCFAllocatorDefault, locale, kCFDateFormatterShortStyle, kCFDateFormatterNoStyle   );
        assert(formatDate != NULL);
		
        formatTime = CFDateFormatterCreate(kCFAllocatorDefault, locale, kCFDateFormatterNoStyle,    kCFDateFormatterShortStyle);
        assert(formatTime != NULL);
		
        cfDate = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, formatDate, cfModDate);
        assert(cfDate != NULL);
		
        cfTime = CFDateFormatterCreateStringWithDate(kCFAllocatorDefault, formatTime, cfModDate);
        assert(cfTime != NULL);
		
        CFStringGetCString(cfDate, date, sizeof(date), kCFStringEncodingUTF8);
        CFStringGetCString(cfTime, time, sizeof(time), kCFStringEncodingUTF8);
        [outstring appendFormat:@"%10s %10s ", date, time];
		
        CFRelease(cfTime);
        CFRelease(cfDate);
        CFRelease(formatTime);
        CFRelease(formatDate);
        CFRelease(locale);
    }
	
    /* Note that this sample assumes UTF-8 since that's what the Mac OS X
	 FTP server returns, however, some servers may use a different encoding. */
    cfName = CFDictionaryGetValue(dictionary, kCFFTPResourceName);
    if (cfName) {
        assert(CFGetTypeID(cfName) == CFStringGetTypeID());
        CFStringGetCString(cfName, name, sizeof(name), kCFStringEncodingUTF8);
        [outstring appendFormat:@"%s", name];
		
        cfLink = CFDictionaryGetValue(dictionary, kCFFTPResourceLink);
        if (cfLink) {
            assert(CFGetTypeID(cfLink) == CFStringGetTypeID());
            CFStringGetCString(cfLink, link, sizeof(link), kCFStringEncodingUTF8);
            if (strlen(link) > 0) 
				[outstring appendFormat:@" -> %s", link];
        }
    }

	// CFShow(outstring);
	return outstring;
}

- (void) list
{
	if (!self.uname || !self.pword) COMPLAIN_AND_BAIL(@"Please set user name and password first");
	if (!self.urlString) COMPLAIN_AND_BAIL(@"Please set URL string first");
	self.fileListings = [NSMutableArray array];
	MySimpleDirectoryListing((CFStringRef)self.urlString, (CFStringRef) uname, (CFStringRef) pword);
}


+ (void) list: (NSString *) aURLString
{
	sharedInstance.urlString = aURLString;
	[sharedInstance list];
}

#pragma mark ***** Uploads

static void MyUploadCallBack(CFWriteStreamRef writeStream, CFStreamEventType type, void * clientCallBackInfo)
{
    MyStreamInfo     *info = (MyStreamInfo *)clientCallBackInfo;
    CFIndex          bytesRead;
    CFIndex          bytesAvailable;
    CFIndex          bytesWritten;
    CFStreamError    error;
	
    assert(writeStream != NULL);
    assert(info        != NULL);
    assert(info->writeStream == writeStream);
	
    switch (type) {
			
        case kCFStreamEventOpenCompleted: // open complete
            break;
        case kCFStreamEventCanAcceptBytes:
            if (info->leftOverByteCount > 0) {
                bytesRead = 0;
                bytesAvailable = info->leftOverByteCount;
            } else {
                bytesRead = CFReadStreamRead(info->readStream, info->buffer, kMyBufferSize);
                if (bytesRead < 0) {
                    fprintf(stderr, "CFReadStreamRead returned %ld\n", bytesRead);
                    goto exit;
                }
                bytesAvailable = bytesRead;
            }
            bytesWritten = 0;
            
            if (bytesAvailable == 0) {
				DELEGATE_CALLBACK(dataUploadFinished:, NUMBER(info->totalBytesWritten));
                goto exit;
            } else {
                bytesWritten = CFWriteStreamWrite(info->writeStream, info->buffer, bytesAvailable);
                if (bytesWritten > 0) {
					
                    info->totalBytesWritten += bytesWritten;
                    if (bytesWritten < bytesAvailable) {
                        info->leftOverByteCount = bytesAvailable - bytesWritten;
                        memmove(info->buffer, info->buffer + bytesWritten, info->leftOverByteCount);
                    } else {
                        info->leftOverByteCount = 0;
                    }
                } else if (bytesWritten < 0) {
                    fprintf(stderr, "CFWriteStreamWrite returned %ld\n", bytesWritten);
                }
            }
			break;
        case kCFStreamEventErrorOccurred:
            error = CFWriteStreamGetError(info->writeStream);
            fprintf(stderr, "CFReadStreamGetError returned (%d, %ld)\n", error.domain, error.error);
			NSString *reason = [NSString stringWithFormat:@"CFReadStreamGetError returned (%d, %ld)\n", error.domain, error.error];
			DELEGATE_CALLBACK(dataUploadFailed:, reason);
            goto exit;
        case kCFStreamEventEndEncountered:
            fprintf(stderr, "\nUpload complete\n");
            goto exit;
        default:
            fprintf(stderr, "Received unexpected CFStream event (%d)", type);
            break;
    }
    return;
    
exit:
    MyStreamInfoDestroy(info);
    CFRunLoopStop(CFRunLoopGetCurrent());
    return;
}

static Boolean MySimpleUpload(CFStringRef uploadDirectory, CFURLRef fileURL, CFStringRef username, CFStringRef password)
{
    CFWriteStreamRef       writeStream;
    CFReadStreamRef        readStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               uploadURL, destinationURL;
    CFStringRef            fileName;
    Boolean                success = true;
    MyStreamInfo           *streamInfo;
	
    assert(uploadDirectory != NULL);
    assert(fileURL != NULL);
    assert( (username != NULL) || (password == NULL) );
    
    /* Create a CFURL from the upload directory string */
    destinationURL = CFURLCreateWithString(kCFAllocatorDefault, uploadDirectory, NULL);
    assert(destinationURL != NULL);
	
    /* Copy the end of the file path and use it as the file name. */
    fileName = CFURLCopyLastPathComponent(fileURL);
    assert(fileName != NULL);
	
    /* Create the destination URL by taking the upload directory and appending the file name. */
    uploadURL = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, destinationURL, fileName, false);
    assert(uploadURL != NULL);
    CFRelease(destinationURL);
    CFRelease(fileName);
    
    /* Create a CFReadStream from the local file being uploaded. */
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
    assert(readStream != NULL);
    
    /* Create an FTP write stream for uploading operation to a FTP URL. If the URL specifies a
	 directory, the open will be followed by a close event/state and the directory will have been
	 created. Intermediary directory structure is not created. */
    writeStream = CFWriteStreamCreateWithFTPURL(kCFAllocatorDefault, uploadURL);
    assert(writeStream != NULL);
    CFRelease(uploadURL);
    
    /* Initialize our MyStreamInfo structure, which we use to store some information about the stream. */
    MyStreamInfoCreate(&streamInfo, readStream, writeStream);
    context.info = (void *)streamInfo;
	
    /* CFReadStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
	 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
	 listen to the run loop source to find out when the open completes and whether it was successful. */
    success = CFReadStreamOpen(readStream);
    if (success) {
        
        /* CFWriteStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
        success = CFWriteStreamSetClient(writeStream, kNetworkEvents, MyUploadCallBack, &context);
        if (success) {
            /* Schedule a run loop on which the client can be notified about stream events.  The client
			 callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
			 the run loop is running. */
            CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
            MyCFStreamSetUsernamePassword(writeStream, username, password);
            // MyCFStreamSetFTPProxy(writeStream, &streamInfo->proxyDict); // no proxies!
            
            /* CFWriteStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
			 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
			 listen to the run loop source to find out when the open completes and whether it was successful. */		
            success = CFWriteStreamOpen(writeStream);
            if (success == false) {
                fprintf(stderr, "CFWriteStreamOpen failed\n");
                MyStreamInfoDestroy(streamInfo);
            }
        } else {
            fprintf(stderr, "CFWriteStreamSetClient failed\n");
            MyStreamInfoDestroy(streamInfo);
        }
    } else {
        fprintf(stderr, "CFReadStreamOpen failed\n");
        MyStreamInfoDestroy(streamInfo);
    }
    return success;
}

- (void) put: (NSString *) fileLocation
{	
	if (!self.uname || !self.pword) COMPLAIN_AND_BAIL(@"Please set user name and password first");
	if (!self.urlString) COMPLAIN_AND_BAIL(@"Please set URL string first");
	
	NSString *readPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileLocation];
	CFURLRef readURL = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *) [readPath UTF8String], [readPath length], NO);
	MySimpleUpload((CFStringRef)self.urlString, readURL, (CFStringRef)uname, (CFStringRef)pword);
	CFRelease(readURL);
}

+ (void) upload: (NSString *) anItem
{
	[sharedInstance put: anItem];
}

#pragma mark ***** Downloads

static void MyDownloadCallBack(CFReadStreamRef readStream, CFStreamEventType type, void * clientCallBackInfo)
{
    MyStreamInfo      *info = (MyStreamInfo *)clientCallBackInfo;
    CFIndex           bytesRead = 0, bytesWritten = 0;
    CFStreamError     error;
    CFNumberRef       cfSize;
    SInt64            size;
    float             progress;
  
    assert(readStream != NULL);
    assert(info       != NULL);
    assert(info->readStream == readStream);
	
    switch (type) {			
        case kCFStreamEventOpenCompleted:
            cfSize = CFReadStreamCopyProperty(info->readStream, kCFStreamPropertyFTPResourceSize);
            if (cfSize) {
                if (CFNumberGetValue(cfSize, kCFNumberSInt64Type, &size)) {
                    fprintf(stderr, "File size is %" PRId64 "\n", size);
                    info->fileSize = size;
                }
                CFRelease(cfSize);
            } else {
                fprintf(stderr, "File size is unknown. Uh oh.\n");
                assert(info->fileSize == 0); 
            }
            break;
        case kCFStreamEventHasBytesAvailable:
            /* CFReadStreamRead will return the number of bytes read, or -1 if an error occurs
			 preventing any bytes from being read, or 0 if the stream's end was encountered. */
            bytesRead = CFReadStreamRead(info->readStream, info->buffer, kMyBufferSize);
            if (bytesRead > 0) {
                bytesWritten = 0;
                while (bytesWritten < bytesRead) {
                    CFIndex result;
					
                    result = CFWriteStreamWrite(info->writeStream, info->buffer + bytesWritten, bytesRead - bytesWritten);
                    if (result <= 0) {
                        fprintf(stderr, "CFWriteStreamWrite returned %ld\n", result);
                        goto exit;
                    }
                    bytesWritten += result;
                }
                info->totalBytesWritten += bytesWritten;
            } else {
                /* If bytesRead < 0, we've hit an error.  If bytesRead == 0, we've hit the end of the file.  
				 In either case, we do nothing, and rely on CF to call us with kCFStreamEventErrorOccurred 
				 or kCFStreamEventEndEncountered in order for us to do our clean up. */
            }
            
            if (info->fileSize > 0) {
                progress = ((float)info->totalBytesWritten/(float)info->fileSize);
				DELEGATE_CALLBACK(progressAtPercent:, NUMBER(progress));
            }
            break;
        case kCFStreamEventErrorOccurred:
            error = CFReadStreamGetError(info->readStream);
			NSString *reason = [NSString stringWithFormat:@"CFReadStreamGetError returned (%d, %ld)\n", error.domain, error.error];
            fprintf(stderr, "CFReadStreamGetError returned (%d, %ld)\n", error.domain, error.error);
			DELEGATE_CALLBACK(dataDownloadFailed:, reason);
            goto exit;
        case kCFStreamEventEndEncountered:
			DELEGATE_CALLBACK(downloadFinished, nil);
            fprintf(stderr, "\nDownload complete\n");
            goto exit;
        default:
            fprintf(stderr, "Received unexpected CFStream event (%d)", type);
            break;
    }
    return;
    
exit:    
    MyStreamInfoDestroy(info);
    CFRunLoopStop(CFRunLoopGetCurrent());
    return;
}

static Boolean MySimpleDownload(CFStringRef urlString, CFURLRef destinationFolder, CFStringRef username, CFStringRef password)
{
    CFReadStreamRef        readStream;
    CFWriteStreamRef       writeStream;
    CFStreamClientContext  context = { 0, NULL, NULL, NULL, NULL };
    CFURLRef               downloadPath, downloadURL;
    CFStringRef            fileName;
    Boolean                success = true;
	BOOL				   dirPath;
    MyStreamInfo           *streamInfo;
	
    assert(urlString != NULL);
    assert(destinationFolder != NULL);
    assert( (username != NULL) || (password == NULL) );
	
	[[NSFileManager defaultManager] fileExistsAtPath:[(NSURL *)destinationFolder path] isDirectory: &dirPath];
    if (!dirPath) {
        fprintf(stderr, "Download destination must be a directory.\n");
        return false;
    }
    
    /* Create a CFURL from the urlString. */
    downloadURL = CFURLCreateWithString(kCFAllocatorDefault, urlString, NULL);
    assert(downloadURL != NULL);
	
    /* Copy the end of the file path and use it as the file name. */
    fileName = CFURLCopyLastPathComponent(downloadURL);
    assert(fileName != NULL);
	
    /* Create the downloadPath by taking the destination folder and appending the file name. */
    downloadPath = CFURLCreateCopyAppendingPathComponent(kCFAllocatorDefault, destinationFolder, fileName, false);
    assert(downloadPath != NULL);
    CFRelease(fileName);
	
    /* Create a CFWriteStream for the file being downloaded. */
    writeStream = CFWriteStreamCreateWithFile(kCFAllocatorDefault, downloadPath);
    assert(writeStream != NULL);
    CFRelease(downloadPath);
    
    /* CFReadStreamCreateWithFTPURL creates an FTP read stream for downloading from an FTP URL. */
    readStream = CFReadStreamCreateWithFTPURL(kCFAllocatorDefault, downloadURL);
    assert(readStream != NULL);
    CFRelease(downloadURL);
    
    /* Initialize our MyStreamInfo structure, which we use to store some information about the stream. */
    MyStreamInfoCreate(&streamInfo, readStream, writeStream);
    context.info = (void *)streamInfo;
	
    /* CFWriteStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
	 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
	 listen to the run loop source to find out when the open completes and whether it was successful. */
    success = CFWriteStreamOpen(writeStream);
    if (success) {
		
        /* CFReadStreamSetClient registers a callback to hear about interesting events that occur on a stream. */
        success = CFReadStreamSetClient(readStream, kNetworkEvents, MyDownloadCallBack, &context);
        if (success) {
			
            /* Schedule a run loop on which the client can be notified about stream events.  The client
			 callback will be triggered via the run loop.  It's the caller's responsibility to ensure that
			 the run loop is running. */
            CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            
            MyCFStreamSetUsernamePassword(readStream, username, password);
            // MyCFStreamSetFTPProxy(readStream, &streamInfo->proxyDict);
            
            /* Setting the kCFStreamPropertyFTPFetchResourceInfo property will instruct the FTP stream
			 to fetch the file size before downloading the file.  Note that fetching the file size adds
			 some time to the length of the download.  Fetching the file size allows you to potentially
			 provide a progress dialog during the download operation. You will retrieve the actual file
			 size after your CFReadStream Callback gets called with a kCFStreamEventOpenCompleted event. */
            CFReadStreamSetProperty(readStream, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
            
            /* CFReadStreamOpen will return success/failure.  Opening a stream causes it to reserve all the
			 system resources it requires.  If the stream can open non-blocking, this will always return TRUE;
			 listen to the run loop source to find out when the open completes and whether it was successful. */
            success = CFReadStreamOpen(readStream);
            if (success == false) {
                fprintf(stderr, "CFReadStreamOpen failed\n");
                MyStreamInfoDestroy(streamInfo);
            }
        } else {
            fprintf(stderr, "CFReadStreamSetClient failed\n");
            MyStreamInfoDestroy(streamInfo);
        }
    } else {
        fprintf(stderr, "CFWriteStreamOpen failed\n");
        MyStreamInfoDestroy(streamInfo);
    }
	
    return success;
}

- (void) fetch: (NSString *) anItem
{
	if (!self.uname || !self.pword) COMPLAIN_AND_BAIL(@"Please set user name and password first");
	if (!self.urlString) COMPLAIN_AND_BAIL(@"Please set URL string first");
	
	NSString *ftpRequest = [NSString stringWithFormat:@"%@/%@", self.urlString, [anItem stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	CFShow(ftpRequest);
	NSString *writepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	self.filePath = [writepath stringByAppendingPathComponent:anItem];
	CFURLRef writeURL = CFURLCreateFromFileSystemRepresentation (NULL, (const UInt8 *) [writepath UTF8String], [writepath length], NO);	
	MySimpleDownload((CFStringRef)ftpRequest, writeURL, (CFStringRef) self.uname, (CFStringRef)self.pword);
}

+ (void) download:(NSString *) anItem
{
	[sharedInstance fetch:anItem];
}
#pragma mark Class

+ (FTPHelper *) sharedInstance
{
	if(!sharedInstance) sharedInstance = [[self alloc] init];
    return sharedInstance;
}
@end