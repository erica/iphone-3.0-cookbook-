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

File: TCPService.m
Abstract: Convenience class that acts as a controller for a listening TCP port
that accepts incoming connections.

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

#import "TCPService.h"
#import "NetUtilities.h"
#import "Networking_Internal.h"

//FUNCTIONS:

static void _AcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void* data, void* info)
{
	NSAutoreleasePool*		localPool = [NSAutoreleasePool new];
	TCPService*				service = (TCPService*)info;
	
	if(kCFSocketAcceptCallBack == type)
	[service handleNewConnectionWithSocket:*(CFSocketNativeHandle*)data fromRemoteAddress:(CFDataGetLength(address) >= sizeof(struct sockaddr) ? (const struct sockaddr*)CFDataGetBytePtr(address) : NULL)];
	
	[localPool release];
}

//CLASS IMPLEMENTATION:

@implementation TCPService

@synthesize running=_running;

- (id) initWithPort:(UInt16)port
{
	if((self = [super init]))
	_port = port;
	
	return self;
}

- (void) dealloc
{
	[self stop];
	
	[super dealloc];
}

- (void) handleNewConnectionWithSocket:(NSSocketNativeHandle)socket fromRemoteAddress:(const struct sockaddr*)address
{
	close(socket);
	
	[self doesNotRecognizeSelector:_cmd];
}

- (BOOL) startUsingRunLoop:(NSRunLoop*)runLoop
{
    CFSocketContext				socketCtxt = {0, self, NULL, NULL, NULL};
	int							yes = 1;
	struct sockaddr_in			addr4;
	CFRunLoopSourceRef			source;
	socklen_t					length;
	
	if(_runLoop)
	return NO;
	_runLoop = runLoop;
	if(!_runLoop)
	return NO;
	[_runLoop retain];
	
	_ipv4Socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&_AcceptCallBack, &socketCtxt);
	if(!_ipv4Socket) {
		[self stop];
		return NO;
	}
	setsockopt(CFSocketGetNative(_ipv4Socket), SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));
	
	
	bzero(&addr4, sizeof(addr4));
	addr4.sin_len = sizeof(addr4);
	addr4.sin_family = AF_INET;
	addr4.sin_port = htons(_port);
	addr4.sin_addr.s_addr = htonl(INADDR_ANY); //NOTE: INADDR_ANY is defined as a host-endian constant, so it should be byte swapped
	if(CFSocketSetAddress(_ipv4Socket, (CFDataRef)[NSData dataWithBytes:&addr4 length:sizeof(addr4)]) != kCFSocketSuccess) {
		[self stop];
		return NO;
	}
	length = sizeof(struct sockaddr_in);
	_localAddress = malloc(length);
	if(getsockname(CFSocketGetNative(_ipv4Socket), _localAddress, &length) < 0)
	[NSException raise:NSInternalInconsistencyException format:@"Unable to retrieve socket address"];
	
	
	source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _ipv4Socket, 0);
	CFRunLoopAddSource([_runLoop getCFRunLoop], source, kCFRunLoopCommonModes);
	CFRelease(source);
	
	
	_running = YES;
	
	return YES;
}

- (BOOL) enableBonjourWithDomain:(NSString*)domain applicationProtocol:(NSString*)protocol name:(NSString*)name
{
	protocol = [TCPConnection bonjourTypeFromIdentifier:protocol];
	if(![domain length])
	domain = @""; //Will use default Bonjour registration doamins, typically just ".local"
	if(![name length])
	name = @""; //Will use default Bonjour name, e.g. the name assigned to the device in iTunes
	
	if(!protocol || !_running)
	return NO;
	
	_netService = [[NSNetService alloc] initWithDomain:domain type:protocol name:name port:[self localPort]];
	if(_netService == NULL)
	return NO;
	
	[_netService scheduleInRunLoop:_runLoop forMode:NSRunLoopCommonModes];
	[_netService publish];
	[_netService setDelegate:self];
	
	return YES;
}

- (void)netServiceDidPublish:(NSNetService *)sender
{
	assert(sender == _netService);
	NSLog(@"%s", _cmd);
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	assert(sender == _netService);
	NSLog(@"%s", _cmd);
}

- (BOOL) isBonjourEnabled
{
	return (_netService ? YES : NO);
}

- (void) disableBonjour
{
	if(_netService) {
		[_netService stop];
		[_netService removeFromRunLoop:_runLoop forMode:NSRunLoopCommonModes];
		[_netService release];
		_netService = nil;
	}
}

- (void) stop
{
	_running = NO;
	
	[self disableBonjour];
	
	if(_ipv4Socket) {
		CFSocketInvalidate(_ipv4Socket);
		CFRelease(_ipv4Socket);
		_ipv4Socket = NULL;
	}
	if(_runLoop) {
		[_runLoop release];
		_runLoop = nil;
	}
	if(_localAddress) {
		free(_localAddress);
		_localAddress = NULL;
	}
}

- (UInt16) localPort
{
	return (_localAddress ? ntohs(((struct sockaddr_in*)_localAddress)->sin_port) : 0);
}

- (UInt32) localIPv4Address
{
	return (_localAddress ? ((struct sockaddr_in*)_localAddress)->sin_addr.s_addr : 0);
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | running = %i | local address = %@>", [self class], (long)self, [self isRunning], SockaddrToString(_localAddress)];
}

@end
