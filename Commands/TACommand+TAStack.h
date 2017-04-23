//
//  TACommand+TAStack.h
//  PHP_IDE
//
//  Created by Thomas Abplanalp on 23.04.17.
//  Copyright © 2017 TASoft Applications. All rights reserved.
//

#import "TACommand.h"

@interface TACommand (TAStack)
+ (instancetype)callStackCommand;
+ (instancetype)callStackWithDepthCommand:(NSInteger)depth;

+ (instancetype)callContextNamesCommand;
+ (instancetype)callContextNamesInStackLevelCommand:(NSInteger)stackLevel;
@end
