//
//  TAConsole.m
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

#import "TAConsole.h"

@implementation TAConsole {
	NSOperationQueue *tasks, *listeners;
	void(^outputHandler)(NSData *);
	void(^errorHandler)(NSData *);
	bool cancelled;
}

- (void)setOutputRedirect:(void(^)(NSData *))handler {
	outputHandler = handler;
}
- (void)setErrorRedirect:(void(^)(NSData *))handler {
	errorHandler = handler;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		tasks = [NSOperationQueue new];
		listeners = [NSOperationQueue new];
		tasks.maxConcurrentOperationCount = 1;
	}
	return self;
}

- (void)runTask:(NSTask *)task completeHandler:(void (^)(NSTask *, BOOL))handler {
	NSPipe *output = [NSPipe pipe];
	NSPipe *error = [NSPipe pipe];
	
	[task setStandardOutput:output];
	[task setStandardError:error];
	
	NSFileHandle *outFH = output.fileHandleForReading;
	NSFileHandle *errFH = error.fileHandleForReading;
	
	NSCondition *waitOut = [NSCondition new];
	NSCondition *waitErr = [NSCondition new];
	NSCondition *waitTask = [NSCondition new];
	
	cancelled = false;
	
	NSBlockOperation *listenOutput = [NSBlockOperation blockOperationWithBlock:^{
		[waitOut lock];
		[waitOut wait];
		[waitOut unlock];
		NSData *data = nil;
		while ((data = [outFH availableData]) && data.length) {
			[self sendOutput:data];
		}
		
		[waitTask signal];
	}];
	
	NSBlockOperation *listenError = [NSBlockOperation blockOperationWithBlock:^{
		[waitErr lock];
		[waitErr wait];
		[waitErr unlock];
		
		NSData *data = nil;
		while ((data = [errFH availableData]) && data.length) {
			[self sendError:data];
		}
	}];
	
	[tasks addOperationWithBlock:^{
		[waitTask lock];
		
		[task launch];
		[waitOut signal];
		[waitErr signal];
		
		[waitTask wait];
		[waitTask unlock];
		
		if(handler)
			handler(task, YES);
	}];
	
	[listeners addOperation:listenOutput];
	[listeners addOperation:listenError];
}

- (void)cancelTasks {
	cancelled = true;
	[tasks cancelAllOperations];
	[listeners cancelAllOperations];
}

- (void)sendOutput:(NSData *)data {
	if(cancelled)
		return;
	
	void(^block)() = ^{
		if(outputHandler) {
			outputHandler(data);
			return;
		}
		printf("%s", data.bytes);
	};
	
	if([NSThread isMainThread])
		block();
	else
		dispatch_async(dispatch_get_main_queue(), block);
}

- (void)sendError:(NSData *)data {
	if(cancelled)
		return;
	
	void(^block)() = ^{
		if(errorHandler) {
			errorHandler(data);
			return;
		}
		printf("%s", data.bytes);
	};
	
	if([NSThread isMainThread])
		block();
	else
		dispatch_async(dispatch_get_main_queue(), block);
}
@end
