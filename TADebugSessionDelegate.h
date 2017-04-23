//
//  TADebugSessionDelegate.h
//  PHP_IDE
//
//  Created by Thomas Abplanalp on 23.04.17.
//  Copyright © 2017 TASoft Applications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAErrorResponse.h"

@class TADebugSession, TAInitialResponse;

@protocol TADebugSessionDelegate <NSObject>
@required
- (void)session:(TADebugSession *)session connectionDidFail:(NSError *)error;

@optional
- (void)session:(TADebugSession *)session didConnectToDebuggerWithResponse:(TAInitialResponse *)response;

- (BOOL)session:(TADebugSession *)session hasScriptAvailableForFile:(NSString *)file line:(NSUInteger)line;
- (void)session:(TADebugSession *)session breakedInFile:(NSString *)file line:(NSUInteger)line;

- (void)sessionDidTerminate:(TADebugSession *)session;

- (void)session:(TADebugSession *)session didReceiveErrorWithCode:(TAErrorCode)code message:(NSString *)message shouldStopResponseHandler:(BOOL*)stop;
@end
