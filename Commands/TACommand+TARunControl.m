//
//  TACommand+TARunControl.m
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


#import "TACommand+TARunControl.h"

@implementation TACommand (TARunControl)
+ (instancetype)quitCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"quit";
	return cmd;
}

+ (instancetype)runCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"run";
	return cmd;
}

+ (instancetype)stopCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"stop";
	return cmd;
}

+ (instancetype)stepOverCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"step_over";
	return cmd;
}
+ (instancetype)stepIntoCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"step_into";
	return cmd;
}
+ (instancetype)stepOutCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"step_out";
	return cmd;
}
@end
