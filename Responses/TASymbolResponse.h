//
//  TASymbolResponse.h
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

#import "TAResponse.h"


extern NSString *TASymbolNameKey;
extern NSString *TASymbolFullNameKey;
extern NSString *TASymbolClassNameKey;

extern NSString *TASymbolTypeKey;
extern NSString *TASymbolContentKey;

extern NSString *TASymbolIsConstantKey;
extern NSString *TASymbolHasChildrenKey;
extern NSString *TASymbolChildrenCountKey;

extern NSString *TASymbolPageKey;
extern NSString *TASymbolPageSizeKey;
extern NSString *TASymbolFacetKey;

extern NSString *TASymbolReferenceKey;
extern NSString *TASymbolAddresTAey;

extern NSString *TASymbolChildrenKey;

typedef enum {
	TAUninitializedType			= -1,
	TAUndefinedType,
	TANullType,
	
	TABooleanType,
	TAIntegerType,
	TAFloatType,
	TAStringType,
	
	TAArrayType,		// Indexed array beginning with 0
	TADictionaryType,	// Associative array
	
	TAObjectType,
	TAResourceType
} TASymbolType;


TASymbolType TASymbolTypeFromString(NSString *string);
NSString *TAStringFromSymbolType(TASymbolType type);

NSString *TALocalizedStringFromSymbolType(TASymbolType type);
TASymbolType TASymbolTypeFromLocalizedString(NSString *string);


@interface TASymbolResponse : TAResponse
@property (nonatomic, readonly) NSDictionary *symbolInfo;
@end
