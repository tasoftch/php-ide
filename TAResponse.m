//
//  TAResponse.m
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

#import "TAResponses.h"

@implementation TAResponse
+ (instancetype)responseWithXMLElement:(NSXMLElement *)element {
	if([element.name isEqualToString:@"init"])
		return [TAInitialResponse responseWithXMLElement:element];
	
	TAErrorResponse *r = [TAErrorResponse responseWithXMLElement:element];
	if(r)
		return r;
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"status"].stringValue isEqualToString:@"break"] && [element attributeForName:@"filename"].stringValue)
		return [TAPositionResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"status"])
		return [TAStatusResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue hasPrefix:@"breakpoint"])
		return [TABreakpointResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"run"])
		return [TAPositionResponse responseWithXMLElement:element];
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"step_over"])
		return [TAPositionResponse responseWithXMLElement:element];
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"step_into"])
		return [TAPositionResponse responseWithXMLElement:element];
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"step_out"])
		return [TAPositionResponse responseWithXMLElement:element];
	
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"stack_get"])
		return [TACallStackResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"context_names"])
		return [TAContextResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"context_get"])
		return [TAContextResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"property_get"])
		return [TASymbolResponse responseWithXMLElement:[[element elementsForName:@"property"] firstObject]];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"eval"])
		return [TAEvalResponse responseWithXMLElement:element];
	
	if([element.name isEqualToString:@"response"] && [[element attributeForName:@"command"].stringValue isEqualToString:@"source"])
		return [TASourceResponse responseWithXMLElement:element];
	
	return nil;
}
@end
