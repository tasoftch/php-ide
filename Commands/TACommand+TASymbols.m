//
//  TACommand+TASymbols.m
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

#import "TACommand+TASymbols.h"

@implementation TACommand (TASymbols)
+ (instancetype)callVariablesCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"context_get";
	return cmd;
}
+ (instancetype)callVariablesInContextCommand:(NSInteger)contextID {
	TACommand *cmd = [TACommand new];
	cmd.name = @"context_get";
	cmd.arguments = @[@"-c", @(contextID)];
	return cmd;
}
+ (instancetype)callVariableInStackLevelCommand:(NSInteger)stackLevel {
	TACommand *cmd = [TACommand new];
	cmd.name = @"context_get";
	cmd.arguments = @[@"-d", @(stackLevel)];
	return cmd;
}
+ (instancetype)callVariablesInContext:(NSInteger)contextID andStackLevelCommand:(NSInteger)stackLevel {
	TACommand *cmd = [TACommand new];
	cmd.name = @"context_get";
	cmd.arguments = @[@"-c", @(contextID), @"-d", @(stackLevel)];
	return cmd;
}
+ (instancetype)callVariableContentCommand:(NSString *)fullVarName context:(NSInteger)contextID stackLevel:(NSInteger)stack {
	TACommand *cmd = [TACommand new];
	cmd.name = @"property_get";
	cmd.arguments = @[@"-n", fullVarName, @"-d", @(stack), @"-c", @(contextID)];
	return cmd;
}
@end
