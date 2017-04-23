//
//  TASymbolResponse.m
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

#import "TASymbolResponse.h"


NSString *TASymbolNameKey = @"TASymbolNameKey";
NSString *TASymbolFullNameKey = @"TASymbolFullNameKey";
NSString *TASymbolTypeKey = @"TASymbolTypeKey";
NSString *TASymbolContentKey = @"TASymbolContentKey";
NSString *TASymbolIsConstantKey = @"TASymbolIsConstantKey";
NSString *TASymbolHasChildrenKey = @"TASymbolHasChildrenKey";
NSString *TASymbolClassNameKey = @"TASymbolClassNameKey";
NSString *TASymbolPageKey = @"TASymbolPageKey";
NSString *TASymbolPageSizeKey = @"TASymbolPageSizeKey";
NSString *TASymbolFacetKey = @"TASymbolFacetKey";

NSString *TASymbolReferenceKey = @"TASymbolReferenceKey";
NSString *TASymbolAddresTAey = @"TASymbolAddresTAey";

NSString *TASymbolChildrenKey = @"TASymbolChildrenKey";
NSString *TASymbolChildrenCountKey = @"TASymbolChildrenCountKey";

__strong NSDictionary *typeLocalisation;


void _LoadTypeLocalisation() {
	if(!typeLocalisation) {
		typeLocalisation = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TypeLocalisation" ofType:@"strings"]];
	}
}



TASymbolType TASymbolTypeFromString(NSString *string) {
	string = [string lowercaseString];
	
	if([string isEqualToString:@"int"] || [string isEqualToString:@"integer"])
		return TAIntegerType;
	if([string isEqualToString:@"null"])
		return TANullType;
	if([string isEqualToString:@"bool"])
		return TABooleanType;
	if([string isEqualToString:@"float"] || [string isEqualToString:@"double"])
		return TAFloatType;
	if([string isEqualToString:@"string"])
		return TAStringType;
	if([string isEqualToString:@"array"])
		return TAArrayType;
	if([string isEqualToString:@"hash"])
		return TADictionaryType;
	if([string isEqualToString:@"object"])
		return TAObjectType;
	if([string isEqualToString:@"resource"])
		return TAResourceType;
	if([string isEqualToString:@"uninitialized"])
		return TAUninitializedType;
	
	return TAUndefinedType;
}

NSString *TAStringFromSymbolType(TASymbolType type) {
	switch (type) {
		case TANullType: return @"null";
		case TAArrayType: return @"array";
		case TAFloatType: return @"float";
		case TAObjectType: return @"object";
		case TAStringType: return @"string";
		case TABooleanType: return @"bool";
		case TAIntegerType: return @"int";
		case TAResourceType: return @"resource";
		case TADictionaryType: return @"hash";
		case TAUninitializedType: return @"uninitialized";
		default: break;
	}
	return @"Mixed";
}

NSString *TALocalizedStringFromSymbolType(TASymbolType type) {
	_LoadTypeLocalisation();
	NSString *str = TAStringFromSymbolType(type);
	return [typeLocalisation objectForKey:str] ? [typeLocalisation objectForKey:str] : str;
}
TASymbolType TASymbolTypeFromLocalizedString(NSString *string) {
	NSString *str = [[typeLocalisation keysOfEntriesPassingTest:^BOOL(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		if([key isEqualToString:string]) {
			*stop = YES;
			return YES;
		}
		return NO;
	}].allObjects firstObject];
	if(str)
		return TASymbolTypeFromString(str);
	return TAUndefinedType;
}



@implementation TASymbolResponse
+ (NSString *)getDecryptedContentOfElement:(NSXMLElement *)element {
	NSString *coding = [element attributeForName:@"encoding"].stringValue;
	NSString *value = [element stringValue];
	
	if([coding isEqualToString:@"base64"]) {
		NSData *data = [[NSData alloc] initWithBase64EncodedString:value options:0];
		value = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	}
	
	return value;
}

+ (id)responseWithXMLElement:(NSXMLElement *)element {
	
	TASymbolResponse *resp = [self.class new];
	NSMutableDictionary *dict = [NSMutableDictionary new];
	NSXMLElement *helper = nil;
	
	if((helper = [[element elementsForName:@"name"] firstObject])) {
		[dict setValue:[self getDecryptedContentOfElement:helper] forKey:TASymbolNameKey];
	}
	else
		[dict setValue:[element attributeForName:@"name"].stringValue forKey:TASymbolNameKey];
	
	if((helper = [[element elementsForName:@"fullname"] firstObject])) {
		[dict setValue:[self getDecryptedContentOfElement:helper] forKey:TASymbolFullNameKey];
	}
	else
		[dict setValue:[element attributeForName:@"fullname"].stringValue forKey:TASymbolFullNameKey];
	
	if((helper = [[element elementsForName:@"classname"] firstObject])) {
		[dict setValue:[self getDecryptedContentOfElement:helper] forKey:TASymbolClassNameKey];
	}
	else
		[dict setValue:[element attributeForName:@"classname"].stringValue forKey:TASymbolClassNameKey];
	
	if((helper = [[element elementsForName:@"value"] firstObject])) {
		[dict setValue:[self getDecryptedContentOfElement:helper] forKey:TASymbolContentKey];
	}
	else if(![element attributeForName:@"children"].stringValue.boolValue)
		[dict setValue:[self getDecryptedContentOfElement:element]  forKey:TASymbolContentKey];
	
	
	[dict setValue:@(TASymbolTypeFromString([element attributeForName:@"type"].stringValue)) forKey:TASymbolTypeKey];
	
	[dict setValue:@([element attributeForName:@"constant"].stringValue.boolValue) forKey:TASymbolIsConstantKey];
	[dict setValue:@([element attributeForName:@"children"].stringValue.boolValue) forKey:TASymbolHasChildrenKey];
	
	[dict setValue:@([element attributeForName:@"numchildren"].stringValue.integerValue) forKey:TASymbolChildrenCountKey];
	
	
	[dict setValue:@([element attributeForName:@"page"].stringValue.integerValue) forKey:TASymbolPageKey];
	[dict setValue:@([element attributeForName:@"pagesize"].stringValue.integerValue) forKey:TASymbolPageSizeKey];
	[dict setValue:@([element attributeForName:@"address"].stringValue.integerValue) forKey:TASymbolAddresTAey];
	[dict setValue:@([element attributeForName:@"facet"].stringValue.integerValue) forKey:TASymbolFacetKey];
	[dict setValue:@([element attributeForName:@"key"].stringValue.integerValue) forKey:TASymbolReferenceKey];
	
	if([element attributeForName:@"numchildren"].stringValue.integerValue) {
		NSMutableArray *array = [NSMutableArray array];
		
		for(NSXMLElement *property in [element elementsForName:@"property"]) {
			TASymbolResponse *r = [self responseWithXMLElement:property];
			NSDictionary *d = r->_symbolInfo;
			if(d)
				[array addObject:d];
		}
		
		[dict setValue:array forKey:TASymbolChildrenKey];
	}
	
	resp->_symbolInfo = dict;
	return resp;
}
@end
