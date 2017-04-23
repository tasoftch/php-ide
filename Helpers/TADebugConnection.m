//
//  TADebugConnection.m
//  PHP_IDE
//
//  Created by Thomas Abplanalp on 23.04.17.
//	  Copyright © 2017 TASoft Applications. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//	SOFTWARE.

#import "TADebugConnection.h"
#import <sys/socket.h>
#include <netinet/in.h>
#import "stuff.h"

#import "TACommands.h"
#import "TAResponses.h"
#import "TADebugSession.h"


@interface TACommand (TADebugSessionInteraction)
- (char *)rawCommand;
+ (void)reset;
- (void)setTransactionIdentifier;

- (void)wait;
- (void)signal;
@end


@implementation TADebugConnection {
	unsigned _port;
	__strong NSOperationQueue *queue;
	
	struct sockaddr_storage  server_in;
	socklen_t                server_in_len;
	struct sockaddr_storage  client_in;
	socklen_t                client_in_len;
	int                      ssocket;
	int                      fd;
	NSCondition 			*lock, *waitForSetup;
	TACommand				*nextCommand, *lastCommand;
	fd_buf                   cxt;
	__strong TAResponse				*lastResponse;
	
	bool 					initial;
}

- (id)initWithPort:(unsigned)port {
	self = [self init];
	if (self) {
		_port = port;
		queue = [NSOperationQueue new];
		queue.maxConcurrentOperationCount = 1;
		
		waitForSetup = [NSCondition new];
		[queue addOperationWithBlock:^{
			[waitForSetup lock];
			[waitForSetup wait];
			[waitForSetup unlock];
		}];
	}
	return self;
}

- (BOOL)connect:(NSError **)outError {
	memset(&server_in, 0, sizeof(server_in));
	memset(&client_in, 0, sizeof(client_in));
	
	ssocket = socket(AF_INET, SOCK_STREAM, 0);
	
	((struct sockaddr_in *)&server_in)->sin_family = AF_INET;
	((struct sockaddr_in *)&server_in)->sin_addr.s_addr = htonl(INADDR_ANY);
	((struct sockaddr_in *)&server_in)->sin_port = htons((unsigned short int) _port);
	
	server_in_len = sizeof(struct sockaddr_in);
	client_in_len = sizeof(struct sockaddr_in);
	
	if (ssocket < 0) {
		if(outError)
			*outError = [NSError errorWithDomain:@"ch.tasoft.skyline-editor.debug" code:99 userInfo:@{NSLocalizedDescriptionKey:@"Connection Failed", NSLocalizedRecoverySuggestionErrorKey:[NSString stringWithFormat:@"Could not create socket at localhost:%u for debug session.", _port]}];
		return NO;
	}
	
	while (bind(ssocket, (struct sockaddr *) &server_in, server_in_len) < 0) {
		if(outError)
			*outError = [NSError errorWithDomain:@"ch.tasoft.skyline-editor.debug" code:98 userInfo:@{NSLocalizedDescriptionKey:@"Connection Failed", NSLocalizedRecoverySuggestionErrorKey:[NSString stringWithFormat:@"Could not bind AF_INET socket on port %u.", _port]}];
		return NO;
	}
	
	if (listen(ssocket, 0) == -1) {
		if(outError)
			*outError = [NSError errorWithDomain:@"ch.tasoft.skyline-editor.debug" code:98 userInfo:@{NSLocalizedDescriptionKey:@"Connection Failed", NSLocalizedRecoverySuggestionErrorKey:@"Listen call failed."}];
		return NO;
	}
	
	return YES;
}

- (BOOL)waitForDebugger:(NSError **)outError withTimeout:(NSTimeInterval)timeout {
	struct timeval tv;
	fd_set rfds;
	FD_ZERO(&rfds);
	FD_SET(ssocket, &rfds);
	tv.tv_sec = (long)timeout;
	tv.tv_usec = 0;
	
	int iResult = select(ssocket+1, &rfds, (fd_set *) 0, (fd_set *) 0, &tv);
	if(iResult< 0) {
		if(outError)
			*outError = [NSError errorWithDomain:@"ch.tasoft.skyline-editor.debug" code:98 userInfo:@{NSLocalizedDescriptionKey:@"Connection Failed", NSLocalizedRecoverySuggestionErrorKey:@"Connection to debugger could not be established."}];
		return NO;
	}
	
	if(iResult==0) {
		if(outError)
			*outError = [NSError errorWithDomain:@"ch.tasoft.skyline-editor.debug" code:98 userInfo:@{NSLocalizedDescriptionKey:@"Connection Failed", NSLocalizedRecoverySuggestionErrorKey:@"Connection to debugger timed out."}];
		return NO;
	}
	
	fd = accept(ssocket, (struct sockaddr *) &client_in, &client_in_len);
	if (fd == -1) {
		NSLog(@"Why here?");
		return NO;
	}
	
	close(ssocket);
	
	char                    *buffer;
	long                      length;
	cxt.buffer = NULL;
	cxt.buffer_size = 0;
	
	if ((buffer = fd_read_line_delim(fd, &cxt, FD_RL_SOCKET, '\0', &length)) > 0) {
		buffer = fd_read_line_delim(fd, &cxt, FD_RL_SOCKET, '\0', &length);
		
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:[NSData dataWithBytes:buffer length:length] options:0 error:NULL];
		[self parseResponse:doc.rootElement];
		
		char *cmd = "status -i 0";
		initial = true;
		
		if (send(fd, cmd, strlen(cmd), 0) == -1) {
			return NO;
		}
		
		if (send(fd, "\0", 1, 0) == -1) {
			return NO;
		}
	}
	return YES;
}

- (void)parseResponse:(NSXMLElement *)xml {
	lastResponse = [TAResponse responseWithXMLElement:xml];
	if([lastResponse isKindOfClass:[TAInitialResponse class]]) {
		if([self.session.delegate respondsToSelector:@selector(session:didConnectToDebuggerWithResponse:)])
			[self.session.delegate session:self.session didConnectToDebuggerWithResponse:(TAInitialResponse *)lastResponse];
		lastResponse = nil;
	}
	
	if([lastResponse isKindOfClass:[TAErrorResponse class]]) {
		TAErrorResponse *r = (TAErrorResponse *)lastResponse;
		
		if([self.session.delegate respondsToSelector:@selector(session:didReceiveErrorWithCode:message:shouldStopResponseHandler:)]) {
			BOOL stop = NO;
			[self.session.delegate session:self.session didReceiveErrorWithCode:r.code message:r.message shouldStopResponseHandler:&stop];
			if(stop)
				lastResponse = nil;
		}
	}
}

- (void)runDebug {
	char                    *buffer;
	long                      length;
	char                    *cmd;
	
	[TACommand reset];
	
	
	while ((buffer = fd_read_line_delim(fd, &cxt, FD_RL_SOCKET, '\0', &length)) > 0) {
		buffer = fd_read_line_delim(fd, &cxt, FD_RL_SOCKET, '\0', &length);
		
		if(LogCommands)
			printf("Response: %s\n", buffer);
		
		NSXMLDocument *doc = [[NSXMLDocument alloc] initWithData:[NSData dataWithBytes:buffer length:length] options:0 error:NULL];
		
		
		
		[self parseResponse:doc.rootElement];
		
		if(initial == false) {
			[lastCommand signal];
		}
		initial = false;
		[waitForSetup signal];
		
		if (strstr(buffer, "<stream") == NULL)
			{
			
			
			/* The server requires a new command */
			lock = [NSCondition new];
			
			[lock lock];
			[lock wait];
			[lock unlock];
			
			if ((cmd = [nextCommand rawCommand])) {
				
				if(LogCommands)
					printf("Command: %s\n", cmd);
				
				/* Send the command to the debug server */
				if (send(fd, cmd, strlen(cmd), 0) == -1) {
					break;
				}
				
				if (send(fd, "\0", 1, 0) == -1) {
					break;
				}
				
				lastCommand = nextCommand;
				
				/* If cmd is quit exit from while */
				if (strncmp(cmd, "quit", 4) == 0) {
					break;
				}
			}
			}
	}
	[lastCommand signal];
	[self close];
}

- (void)sendCommand:(TACommand *)command responseHandler:(void(^)(TACommand*, __kindof TAResponse *))handler {
	if(command.name.length < 1)
		return;
	
	[queue addOperationWithBlock:^{
		[command setTransactionIdentifier];
		
		
		nextCommand = command;
		[lock signal];
		[command wait];
		
		if(lastResponse)
			handler(command, lastResponse);
	}];
}

- (void)close {
	[queue cancelAllOperations];
	close(fd);
}
@end
