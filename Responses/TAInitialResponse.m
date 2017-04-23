//
//  TAInitialResponse.m
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

#import "TAInitialResponse.h"

@implementation TAInitialResponse
+ (id)responseWithXMLElement:(NSXMLElement *)element {
	TAInitialResponse *resp = [TAInitialResponse new];
	resp->_fileURI = [element attributeForName:@"fileuri"].stringValue;
	resp->_language = [element attributeForName:@"language"].stringValue;
	resp->_languageVersion = [element attributeForName:@"language_version"].stringValue;
	resp->_processID = [element attributeForName:@"appid"].stringValue.integerValue;
	resp->_debugSessionID = [element attributeForName:@"idekey"].stringValue;
	
	NSXMLElement *engine = [[element elementsForName:@"engine"] firstObject];
	resp->_debuggerName = [engine stringValue];
	resp->_debuggerVersion = [engine attributeForName:@"version"].stringValue;
	
	NSXMLElement *author = [[element elementsForName:@"author"] firstObject];
	resp->_authorName = [author stringValue];
	
	NSXMLElement *url = [[element elementsForName:@"url"] firstObject];
	if(url.stringValue)
		resp->_URL = [NSURL URLWithString:url.stringValue];
	
	NSXMLElement *copyright = [[element elementsForName:@"copyright"] firstObject];
	resp->_copyright = copyright.stringValue;
	
	return resp;
}
@end
