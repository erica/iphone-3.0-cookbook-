/*

===== IMPORTANT =====

This is sample code demonstrating API, technology or techniques in development.
Although this sample code has been reviewed for technical accuracy, it is not
final. Apple is supplying this information to help you plan for the adoption of
the technologies and programming interfaces described herein. This information
is subject to change, and software implemented based on this sample code should
be tested with final operating system software and final documentation. Newer
versions of this sample code may be provided with future seeds of the API or
technology. For information about updates to this and other developer
documentation, view the New & Updated sidebars in subsequent documentation
seeds.

=====================

File: TCPConnection.m
Abstract: Convenience class that acts as a controller for TCP based network
connections.

Version: 1.1

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import <unistd.h>
#import <netinet/in.h>

#import <CFNetwork/CFNetwork.h>
#import "TCPConnection.h"
#import "NetUtilities.h"
#import "Networking_Internal.h"

//CONSTANTS:

#define kMagic						0x1234ABCD
#define kOpenedMax					3

//STRUCTURE:

typedef struct {
	NSUInteger		magic;
	NSUInteger		length;
} Header; //NOTE: This header is in big-endian

//CLASS INTERFACES:

@interface TCPConnection (Internal)
- (id) _initWithRunLoop:(NSRunLoop*)runLoop readStream:(CFReadStreamRef)input writeStream:(CFWriteStreamRef)output;
- (void) _handleStreamEvent:(CFStreamEventType)type forStream:(CFTypeRef)stream;
@end

//FUNCTIONS:

static void _ReadClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void* clientCallBackInfo)
{
	NSAutoreleasePool*		localPool = [NSAutoreleasePool new];
	
	[(TCPConnection*)clientCallBackInfo _handleStreamEvent:type forStream:stream];
	
	[localPool release];
}

static void _WriteClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void* clientCallBackInfo)
{
	NSAutoreleasePool*		localPool = [NSAutoreleasePool new];
	
	[(TCPConnection*)clientCallBackInfo _handleStreamEvent:type forStream:stream];
	
	[localPool release];
}

//CLASS IMPLEMENTATION:

@implementation TCPConnection

@synthesize delegate=_delegate;

- (id) initWithSocketHandle:(int)socket
{
	CFReadStreamRef			readStream = NULL;
	CFWriteStreamRef		writeStream = NULL;
	
	CFStreamCreatePairWithSocket(kCFAllocatorDefault, socket, &readStream, &writeStream);
	if(!readStream || !writeStream) {
		close(socket);
		if(readStream)
		CFRelease(readStream);
		if(writeStream)
		CFRelease(writeStream);
		[self release];
		return nil;
	}
	
	CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	self = [self _initWithRunLoop:[NSRunLoop currentRunLoop] readStream:readStream writeStream:writeStream];
	CFRelease(readStream);
	CFRelease(writeStream);
	
	return self;
}

- (id) initWithRemoteAddress:(const struct sockaddr*)address
{
	CFReadStreamRef			readStream = NULL;
	CFWriteStreamRef		writeStream = NULL;
	CFSocketSignature		signature;
	CFDataRef				data;
	
	data = (address ? CFDataCreate(kCFAllocatorDefault, (const UInt8*)address, address->sa_len) : NULL);
	if(data == NULL) {
		[self release];
		return nil;
	}
	
	signature.protocolFamily = PF_INET;
	signature.socketType = SOCK_STREAM;
	signature.protocol = IPPROTO_TCP;
	signature.address = data;
	CFStreamCreatePairWithPeerSocketSignature(kCFAllocatorDefault, &signature, &readStream, &writeStream);
	CFRelease(data);
	if(!readStream || !writeStream) {
		if(readStream)
		CFRelease(readStream);
		if(writeStream)
		CFRelease(writeStream);
		[self release];
		return nil;
	}
	
	self = [self _initWithRunLoop:[NSRunLoop currentRunLoop] readStream:readStream writeStream:writeStream];
	CFRelease(readStream);
	CFRelease(writeStream);
	
	return self;
}

- (id) _initWithRunLoop:(NSRunLoop*)runLoop readStream:(CFReadStreamRef)input writeStream:(CFWriteStreamRef)output
{
	CFStreamClientContext	context = {0, self, NULL, NULL, NULL};
	
	if((self = [super init])) {
		_inputStream = (CFReadStreamRef)CFRetain(input);
		_outputStream = (CFWriteStreamRef)CFRetain(output);
		_runLoop = runLoop;
		[_runLoop retain];
		
		CFReadStreamSetClient(_inputStream, kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, _ReadClientCallBack, &context);
		CFReadStreamScheduleWithRunLoop(_inputStream, [_runLoop getCFRunLoop], kCFRunLoopCommonModes);
		CFWriteStreamSetClient(_outputStream, kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered, _WriteClientCallBack, &context);
		CFWriteStreamScheduleWithRunLoop(_outputStream, [_runLoop getCFRunLoop], kCFRunLoopCommonModes);
		
		if(!CFReadStreamOpen(_inputStream) || !CFWriteStreamOpen(_outputStream)) {
			[self release];
			return nil;
		}
	}
	
	return self;
}

- (void) dealloc
{	
	[self invalidate];
	
	if(_localAddress)
	free(_localAddress);
	if(_remoteAddress)
	free(_remoteAddress);
	
	[super dealloc];
}

- (void) setDelegate:(id<TCPConnectionDelegate>)delegate
{
	_delegate = delegate;
	
	SET_DELEGATE_METHOD_BIT(0, connectionDidFailOpening:);
	SET_DELEGATE_METHOD_BIT(1, connectionDidOpen:);
	SET_DELEGATE_METHOD_BIT(2, connectionDidClose:);
	SET_DELEGATE_METHOD_BIT(3, connection:didReceiveData:);
}

- (BOOL) isValid
{
	return ((_opened >= kOpenedMax) && !_invalidating ? YES : NO);
}

- (void) _invalidate
{
	if(_inputStream) {
		CFReadStreamSetClient(_inputStream, kCFStreamEventNone, NULL, NULL);
		CFReadStreamClose(_inputStream);
		CFRelease(_inputStream);
		_inputStream = NULL;
	}
	
	if(_outputStream) {
		CFWriteStreamSetClient(_outputStream, kCFStreamEventNone, NULL, NULL);
		CFWriteStreamClose(_outputStream);
		CFRelease(_outputStream);
		_outputStream = NULL;
	}
	
	if(_runLoop) {
		[_runLoop release];
		_runLoop = nil;
	}
	
	if(_opened >= kOpenedMax) {
		if(TEST_DELEGATE_METHOD_BIT(2))
		[_delegate connectionDidClose:self];
		_opened = 0;
	}
	else if(TEST_DELEGATE_METHOD_BIT(0))
	[_delegate connectionDidFailOpening:self];
}

- (void) invalidate
{
	if(_invalidating == NO) {
		_invalidating = YES;
		
		[self _invalidate];
	}
}

- (BOOL) _writeData:(NSData*)data
{
	CFIndex					length = [data length],
							result;
	Header					header;
	
	header.magic = NSSwapHostIntToBig(kMagic);
	header.length = NSSwapHostIntToBig(length);
	result = CFWriteStreamWrite(_outputStream, (const UInt8*)&header, sizeof(Header));
	if(result != sizeof(Header)) {
		REPORT_ERROR(@"Wrote only %i bytes out of %i bytes in header", (int)result, (int)sizeof(Header));
		return NO;
	}
	
	while(length > 0) {
		result = CFWriteStreamWrite(_outputStream, (UInt8*)[data bytes] + [data length] - length, length);
		if(result <= 0) {
			REPORT_ERROR(@"Wrote only %i bytes out of %i (%i) bytes in data", (int)result, (int)length, [data length]);
			return NO;
		}
		length -= result;
	}
	
	return YES;
}

- (NSData*) _readData
{
	NSMutableData*			data;
	CFIndex					result,
							length;
	Header					header;
	
	result = CFReadStreamRead(_inputStream, (UInt8*)&header, sizeof(Header));
	if(result == 0)
	return (id)kCFNull;
	if(result != sizeof(Header)) {
		REPORT_ERROR(@"Read only %i bytes out of %i bytes in header", (int)result, (int)sizeof(Header));
		return nil;
	}
	if(NSSwapBigIntToHost(header.magic) != kMagic) {
		REPORT_ERROR(@"Invalid header", NULL);
		return nil;
	}
	
	length = NSSwapBigIntToHost(header.length);
	data = [NSMutableData dataWithCapacity:length];
	[data setLength:length];
	
	while(length > 0) {
		result = CFReadStreamRead(_inputStream, (UInt8*)[data mutableBytes] + [data length] - length, length);
		if(result <= 0) {
			REPORT_ERROR(@"Read only %i bytes out of %i (%i) bytes in data", (int)result, (int)length, [data length]);
			return nil;
		}
		length -= result;
	}
	
	return data;
}

- (void) _initializeConnection:(CFTypeRef)stream
{
	int						value = 1;
	CFDataRef				data;
	CFSocketNativeHandle	socket;
	socklen_t				length;
	
	if((data = (CFGetTypeID(stream) == CFWriteStreamGetTypeID() ? CFWriteStreamCopyProperty((CFWriteStreamRef)stream, kCFStreamPropertySocketNativeHandle) : CFReadStreamCopyProperty((CFReadStreamRef)stream, kCFStreamPropertySocketNativeHandle)))) {
		CFDataGetBytes(data, CFRangeMake(0, sizeof(CFSocketNativeHandle)), (UInt8*)&socket);
		value = 1;
		setsockopt(socket, SOL_SOCKET, SO_KEEPALIVE, &value, sizeof(value));
		value = sizeof(Header);
		setsockopt(socket, SOL_SOCKET, SO_SNDLOWAT, &value, sizeof(value));
		setsockopt(socket, SOL_SOCKET, SO_SNDLOWAT, &value, sizeof(value));
		CFRelease(data);
		
		length = SOCK_MAXADDRLEN;
		_localAddress = malloc(length);
		if(getsockname(socket, _localAddress, &length) < 0) {
			free(_localAddress);
			_localAddress = NULL;
			REPORT_ERROR(@"Unable to retrieve local address (%i)", errno);
		}
		length = SOCK_MAXADDRLEN;
		_remoteAddress = malloc(length);
		if(getpeername(socket, _remoteAddress, &length) < 0) {
			free(_remoteAddress);
			_remoteAddress = NULL;
			REPORT_ERROR(@"Unable to retrieve remote address (%i)", errno);
		}
		
		if(TEST_DELEGATE_METHOD_BIT(1))
		[_delegate connectionDidOpen:self]; //NOTE: Connection may have been invalidated after this call!
	}
	else
	[NSException raise:NSInternalInconsistencyException format:@"Unable to retrieve socket from CF stream"];
}

/* Behavior notes regarding socket based CF streams:
- The connection is really ready once both input & output streams are opened and the output stream is writable
- The connection can receive a "has bytes available" notification before it's ready as defined above, in which case it should be ignored as there seems to be no bytes available to read anyway
*/
- (void) _handleStreamEvent:(CFStreamEventType)type forStream:(CFTypeRef)stream
{
	NSData*				data;
	CFStreamError		error;
	
	
	switch(type) {
		
		case kCFStreamEventOpenCompleted:
		if(_opened < kOpenedMax) {
			_opened += 1;
			if(_opened == kOpenedMax)
			[self _initializeConnection:stream];
		}
		break;
		
		case kCFStreamEventHasBytesAvailable: //NOTE: kCFStreamEventHasBytesAvailable will be sent for 0 bytes available to read when stream reaches end
		if(_opened >= kOpenedMax) {
			do {
				data = [self _readData];
				if(data != (id)kCFNull) {
					if(data == nil) {
						[self invalidate]; //NOTE: "self" might have been already de-alloced after this call!
						return;
					}
					else {
						if((_invalidating == NO) && TEST_DELEGATE_METHOD_BIT(3))
						[_delegate connection:(id)self didReceiveData:data]; //NOTE: Avoid type conflict with NSURLConnection delegate
					}
				}
			} while(!_invalidating && CFReadStreamHasBytesAvailable(_inputStream));
		}
		break;
		
		case kCFStreamEventCanAcceptBytes:
		if(_opened < kOpenedMax) {
			_opened += 1;
			if(_opened == kOpenedMax)
			[self _initializeConnection:stream];
		}
		break;
		
		case kCFStreamEventErrorOccurred:
		error = (CFGetTypeID(stream) == CFWriteStreamGetTypeID() ? CFWriteStreamGetError((CFWriteStreamRef)stream) : CFReadStreamGetError((CFReadStreamRef)stream));
		REPORT_ERROR(@"Error (%i) occured in CF stream", (int)error.error);
		case kCFStreamEventEndEncountered:
		[self invalidate];
		break;
				
	}
}

- (BOOL) hasDataAvailable
{
	if(![self isValid])
	return NO;
	
	return CFReadStreamHasBytesAvailable(_inputStream);
}

- (NSData*) receiveData
{
	NSData*				data;
	
	if(![self isValid])
	return nil;
	
	data = [self _readData];
	if(data == nil)
	[self invalidate];
	else if(data == (id)kCFNull)
	data = nil;
	
	return data;
}

- (BOOL) sendData:(NSData*)data
{
	if(![self isValid] || !data)
	return NO;
	
	if(![self _writeData:data]) {
		[self invalidate];
		return NO;
	}
	
	return YES;
}

- (UInt16) localPort
{
	if(_localAddress)
	switch(_localAddress->sa_family) {
		case AF_INET: return ntohs(((struct sockaddr_in*)_localAddress)->sin_port);
		case AF_INET6: return ntohs(((struct sockaddr_in6*)_localAddress)->sin6_port);
	}
	
	return 0;
}

- (UInt32) localIPv4Address
{
	return (_localAddress && (_localAddress->sa_family == AF_INET) ? ((struct sockaddr_in*)_localAddress)->sin_addr.s_addr : 0);
}

- (UInt16) remotePort
{
	if(_remoteAddress)
	switch(_remoteAddress->sa_family) {
		case AF_INET: return ntohs(((struct sockaddr_in*)_remoteAddress)->sin_port);
	}
	
	return 0;
}

- (UInt32) remoteIPv4Address
{
	return (_remoteAddress && (_remoteAddress->sa_family == AF_INET) ? ((struct sockaddr_in*)_remoteAddress)->sin_addr.s_addr : 0);
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | valid = %i | local address = %@ | remote address = %@>", [self class], (long)self, [self isValid], SockaddrToString(_localAddress), SockaddrToString(_remoteAddress)];
}

- (const struct sockaddr*) remoteSocketAddress
{
	return _remoteAddress;
}

+ (NSString*) bonjourTypeFromIdentifier:(NSString*)identifier {
	if (![identifier length])
    return nil;
    
    return [NSString stringWithFormat:@"_%@._tcp.", identifier];
}
@end
