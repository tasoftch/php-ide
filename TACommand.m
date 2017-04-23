//
//  TACommand.m
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

#import "TACommand.h"

static long transID = 1;


@interface TACommand (TADebugSessionInteraction)
- (void)signal;
- (void)wait;
+ (void)reset;
- (void)setTransactionIdentifier;

- (char *)rawCommand;
@end



@implementation TACommand {
	NSCondition *lock;
}

+ (instancetype)commandWithName:(NSString *)name arguments:(NSArray *)arguments expression:(NSString *)expression {
	TACommand *cmd = [TACommand new];
	cmd.name = name;
	cmd.arguments = arguments;
	cmd.expression = expression;
	return cmd;
}

+ (instancetype)commandWithName:(NSString *)name {
	return [self commandWithName:name arguments:nil expression:nil];
}

+ (instancetype)commandWithName:(NSString *)name arguments:(NSArray *)arguments {
	return [self commandWithName:name arguments:arguments expression:nil];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %s", [super description], [self rawCommand]];
}
@end


@implementation TACommand (TADebugSessionInteraction)

- (void)signal {
	[lock signal];
}

- (void)wait {
	lock = [NSCondition new];
	[lock lock];
	[lock wait];
	[lock unlock];
}

+ (void)reset {
	transID = 1;
}

- (void)setTransactionIdentifier {
	[self willChangeValueForKey:@"transactionID"];
	_transactionID = transID++;
	[self didChangeValueForKey:@"transactionID"];
}

- (char *)rawCommand {
	NSMutableString *cmd = [NSMutableString stringWithString:self.name];
	
	if(self.arguments.count) {
		[cmd appendString:@" "];
		[cmd appendString:[self.arguments componentsJoinedByString:@" "]];
	}
	[cmd appendString:@" "];
	[cmd appendFormat:@"-i %lu", self.transactionID];
	if(self.expression.length) {
		[cmd appendString:@" -- "];
		NSData *data = [self.expression dataUsingEncoding:NSUTF8StringEncoding];
		NSString *base64 = [data base64EncodedStringWithOptions:0];
		[cmd appendString:base64];
	}
	return (char *)[cmd UTF8String];
}

@end

