//
//  TAStatusResponse.m
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

#import "TAStatusResponse.h"

@implementation TAStatusResponse
+ (id)responseWithXMLElement:(NSXMLElement *)element {
	TAStatusResponse *resp = [[self class] new];
	NSString *st = [element attributeForName:@"status"].stringValue;
	
	if([st isEqualToString:@"starting"])
		resp->_status = TAStartingState;
	if([st isEqualToString:@"stopping"])
		resp->_status = TAStoppingState;
	if([st isEqualToString:@"stopped"])
		resp->_status = TAStoppedState;
	if([st isEqualToString:@"running"])
		resp->_status = TARunningState;
	if([st isEqualToString:@"break"])
		resp->_status = TABreakState;
	
	st = [element attributeForName:@"reason"].stringValue;
	
	if([st isEqualToString:@"ok"])
		resp->_reason = TADebuggerOKReason;
	if([st isEqualToString:@"error"])
		resp->_reason = TADebuggerErrorReason;
	if([st isEqualToString:@"aborted"])
		resp->_reason = TADebuggerAbortedReason;
	if([st isEqualToString:@"exception"])
		resp->_reason = TADebuggerExceptionReason;
	
	return resp;
}
@end
