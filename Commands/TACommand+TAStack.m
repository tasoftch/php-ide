//
//  TACommand+TAStack.m
//  PHP_IDE
//
//  Created by Thomas Abplanalp on 23.04.17.
//  Copyright © 2017 TASoft Applications. All rights reserved.
//

#import "TACommand+TAStack.h"

@implementation TACommand (TAStack)
+ (instancetype)callStackWithDepthCommand:(NSInteger)depth {
	TACommand *cmd = [TACommand new];
	cmd.name = @"stack_get";
	if(depth)
		cmd.arguments = @[@"-d", @(depth)];
	return cmd;
}

+ (instancetype)callStackCommand { return [self callStackWithDepthCommand:0]; }

+ (instancetype)callContextNamesCommand {
	TACommand *cmd = [TACommand new];
	cmd.name = @"context_names";
	return cmd;
}
+ (instancetype)callContextNamesInStackLevelCommand:(NSInteger)stackLevel {
	TACommand *cmd = [TACommand new];
	cmd.name = @"context_names";
	cmd.arguments = @[@"-d", @(stackLevel)];
	return cmd;
}
@end
