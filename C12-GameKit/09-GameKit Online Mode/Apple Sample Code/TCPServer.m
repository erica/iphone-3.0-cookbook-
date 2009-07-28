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

File: TCPServer.m
Abstract: Subclass of TCPService that implements a full TCP server.

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

#import "TCPServer.h"
#import "Networking_Internal.h"

//CLASS INTERFACES:

@interface TCPServerConnection (Private)
- (void) _setServer:(TCPServer*)server;
@end

@interface TCPServer (Internal)
- (void) _removeConnection:(TCPServerConnection*)connection;
@end

//CLASS IMPLEMENTATIONS:

@implementation TCPServerConnection

@synthesize server=_server;

- (void) _setServer:(TCPServer*)server
{
	_server = server;
}

- (void) _invalidate
{
	TCPServer*			server;
	
	server = [_server retain];
	
	[super _invalidate]; //NOTE: The server delegate may destroy the server when notified this connection was invalidated
	
	[server _removeConnection:self];
	
	[server release];
}

@end

@implementation TCPServer

@synthesize delegate=_delegate;

+ (Class) connectionClass
{
	return [TCPServerConnection class];
}

- (id) initWithPort:(UInt16)port
{
	if((self = [super initWithPort:port])) {
		_connections = [NSMutableSet new];
	}
	
	return self;
}

- (void) dealloc
{
	[self stop]; //NOTE: Make sure our -stop is executed immediately
	
	[_connections release];
	
	[super dealloc];
}

- (void) setDelegate:(id<TCPServerDelegate>)delegate
{
	_delegate = delegate;
	
	SET_DELEGATE_METHOD_BIT(0, serverDidStart:);
	SET_DELEGATE_METHOD_BIT(1, serverDidEnableBonjour:withName:);
	SET_DELEGATE_METHOD_BIT(2, server:shouldAcceptConnectionFromAddress:);
	SET_DELEGATE_METHOD_BIT(3, server:didOpenConnection:);
	SET_DELEGATE_METHOD_BIT(4, server:didCloseConnection:);
	SET_DELEGATE_METHOD_BIT(5, serverWillDisableBonjour:);
	SET_DELEGATE_METHOD_BIT(6, serverWillStop:);
	SET_DELEGATE_METHOD_BIT(7, server:didNotEnableBonjour:);
}

- (BOOL) startUsingRunLoop:(NSRunLoop*)runLoop
{
	if(![super startUsingRunLoop:runLoop])
	return NO;
	
	if(TEST_DELEGATE_METHOD_BIT(0))
	[_delegate serverDidStart:self];
	
	return YES;
}

/*
 Bonjour will not allow conflicting service instance names (in the same domain), and may have automatically renamed
 the service if there was a conflict.  We pass the name back to the delegate so that the name can be displayed to
 the user.
 See http://developer.apple.com/networking/bonjour/faq.html for more information.
 */

- (void)netServiceDidPublish:(NSNetService *)sender
{
	[super netServiceDidPublish:sender];
	if(TEST_DELEGATE_METHOD_BIT(1))
		[_delegate serverDidEnableBonjour:self withName:sender.name];
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	[super netServiceDidPublish:sender];
	if(TEST_DELEGATE_METHOD_BIT(7))
		[_delegate server:self didNotEnableBonjour:errorDict];
}

- (void) disableBonjour
{
	if([self isBonjourEnabled] && TEST_DELEGATE_METHOD_BIT(5))
	[_delegate serverWillDisableBonjour:self];
	
	[super disableBonjour];
}

- (void) stop
{
	NSArray*			connections;
	TCPConnection*		connection;
	
	if([self isRunning] && TEST_DELEGATE_METHOD_BIT(6))
	[_delegate serverWillStop:self];
	
	[super stop];
	
	connections = [self allConnections];
	for(connection in connections)
	[connection invalidate];
}

- (NSArray*) allConnections
{
	NSArray*				connections;
	
	connections = [_connections allObjects];
	
	return connections;
}

- (void) _addConnection:(TCPServerConnection*)connection
{
	[_connections addObject:connection];
	[connection _setServer:self];
	
	if(TEST_DELEGATE_METHOD_BIT(3))
	[_delegate server:self didOpenConnection:connection];
}

- (void) _removeConnection:(TCPServerConnection*)connection
{
	if(TEST_DELEGATE_METHOD_BIT(4))
	[_delegate server:self didCloseConnection:connection];
	
	[connection _setServer:nil];
	[_connections removeObject:connection];
}

- (void) handleNewConnectionWithSocket:(NSSocketNativeHandle)socket fromRemoteAddress:(const struct sockaddr*)address
{
	TCPServerConnection*		connection;
	
	if(!TEST_DELEGATE_METHOD_BIT(2) || [_delegate server:self shouldAcceptConnectionFromAddress:address]) {
		connection = [[[[self class] connectionClass] alloc] initWithSocketHandle:socket];
		if(connection) {
			[self _addConnection:connection];
			[connection release];
		}
		else
		REPORT_ERROR(@"Failed creating TCPServerConnection for socket #%i", socket);
	}
	else
	close(socket);
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | %i connections | super = %@>", [self class], (long)self, [_connections count], [super description]];
}

@end
