//
//  TADebugSession.m
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

#import "TADebugSession.h"
#import "TADebugConnection.h"

#import "TACommands.h"

@implementation TADebugSession {
	__strong NSMutableArray *breakpoints;
	__strong NSOperationQueue *queue;
	__strong TADebugConnection *connection;
	
	bool cancel;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		breakpoints = [NSMutableArray new];
		queue = [NSOperationQueue new];
		self.port = 9090;
	}
	return self;
}

- (void)addBreakpoint:(TABreakpoint *)point {
	if([point isKindOfClass:[TABreakpoint class]] && ![breakpoints containsObject:point]) {
		[breakpoints addObject:point];
	}
}

- (void)removeBreakpoint:(TABreakpoint *)point {
	[breakpoints removeObject:point];
}

- (void)setBreakpoints:(NSArray <TABreakpoint*> *)bps {
	[breakpoints removeAllObjects];
	for(TABreakpoint *bp in bps)
		[self addBreakpoint:bp];
}

- (void)tearDownSession {
	cancel = YES;
	connection = nil;
}

- (void)runAndObservePHPTask:(NSTask *)task inConsole:(TAConsole *)console {
	[console runTask:task completeHandler:^(NSTask *task, BOOL success) {
	}];
}

- (void)setupAndStartSessionWithPHPTask:(NSTask *)task {
	NSAssert(connection == nil, @"Can not start session. Already running.");
	connection = [[TADebugConnection alloc] initWithPort:(unsigned)self.port];
	connection.session = self;
	
	cancel = false;
	
	[queue addOperationWithBlock:^{
		NSError *e = nil;
		if(![connection connect:&e]) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				[self.delegate session:self connectionDidFail:e];
				[self tearDownSession];
			});
		} else {
			[queue addOperationWithBlock:^{
				// Add the php execution script command
				[NSThread sleepForTimeInterval:.5];
				
				[self runAndObservePHPTask:task inConsole:self.console];
			}];
			
			if(![connection waitForDebugger:&e withTimeout:2.0]) {
				
				dispatch_sync(dispatch_get_main_queue(), ^{
					[self.delegate session:self connectionDidFail:e];
					[self tearDownSession];
				});
				return;
			}
			else {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.isRunning = YES;
				});
				[connection runDebug];
			}
		}
	}];
	
	for(TABreakpoint *bp in breakpoints) {
		[connection sendCommand:[TACommand setBreakpointCommand:bp] responseHandler:^(TACommand *cmd, TAResponse *resp) {
			bp.debugID = [(TABreakpointResponse *)resp debugID];
		}];
	}
	
	[connection sendCommand:[TACommand runCommand] responseHandler:^(TACommand *c, TAResponse *r) {
		[self sendPositionResponse:r];
	}];
}


- (void)sendPositionResponse:(TAResponse *)r {
	TAPositionResponse *resp = (TAPositionResponse *)r;
	
	if(resp.status == TAStoppingState) {
		[self stopExecutation:nil];
		return;
	}
	
	dispatch_async(dispatch_get_main_queue(), ^{
		if([self.delegate respondsToSelector:@selector(session:breakedInFile:line:)])
			[self.delegate session:self breakedInFile:resp.filename line:resp.lineNumber];
		
		self.isPausing = YES;
	});
}


- (void)sendCommand:(TACommand *)command withResponseHandler:(void(^)(__kindof TAResponse *))handler {
	
	[connection sendCommand:command responseHandler:^(TACommand *c, __kindof TAResponse *resp) {
		if(_alwaysSendResponseInMainThread) {
			dispatch_async(dispatch_get_main_queue(), ^{
				handler(resp);
			});
		}
		else
			handler(resp);
	}];
}

- (IBAction)continueExecution:(id)sender {
	self.isPausing = NO;
	
	[self sendCommand:[TACommand runCommand] withResponseHandler:^(TAResponse *r) {
		[self sendPositionResponse:r];
	}];
}

- (void)pauseExecutation:(id)sender {
	self.isPausing = NO;
	
	[self sendCommand:[TACommand commandWithName:@"break"] withResponseHandler:^(TAResponse *r) {
		[self sendPositionResponse:r];
	}];
}

- (void)stepOut:(id)sender {
	self.isPausing = NO;
	
	[self sendCommand:[TACommand stepOutCommand] withResponseHandler:^(TAResponse *r) {
		[self sendPositionResponse:r];
	}];
}

- (void)stepOver:(id)sender {
	self.isPausing = NO;
	
	[self sendCommand:[TACommand stepOverCommand] withResponseHandler:^(TAResponse *r) {
		[self sendPositionResponse:r];
	}];
}

- (void)stepInto:(id)sender {
	self.isPausing = NO;
	
	[self sendCommand:[TACommand stepIntoCommand] withResponseHandler:^(TAResponse *r) {
		[self sendPositionResponse:r];
	}];
}

- (void)stopExecutation:(id)sender {
	[self.console cancelTasks];
	[self sendCommand:[TACommand quitCommand] withResponseHandler:^(__kindof TAResponse *resp) {
		
		[self tearDownSession];
		if([self.delegate respondsToSelector:@selector(sessionDidTerminate:)]) {
			if(_alwaysSendResponseInMainThread) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.delegate sessionDidTerminate:self];
				});
			}
			else
				[self.delegate sessionDidTerminate:self];
		}
	}];
}
@end
