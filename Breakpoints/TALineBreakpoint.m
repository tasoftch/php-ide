//
//  TALineBreakpoint.m
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

#import "TALineBreakpoint.h"

@implementation TALineBreakpoint
- (void)encodeWithCoder:(NSCoder *)aCoder {
	[super encodeWithCoder:aCoder];
	[aCoder encodeInteger:self.line forKey:@"line"];
	[aCoder encodeObject:self.filename forKey:@"filename"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if (self) {
		self.filename = [coder decodeObjectForKey:@"filename"];
		self.line = (unsigned)[coder decodeIntegerForKey:@"line"];
	}
	return self;
}

- (id)copyWithZone:(NSZone *)zone {
	TALineBreakpoint *bp = [super copyWithZone:zone];
	bp.line = self.line;
	bp.filename = self.filename;
	return bp;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ %@:%u", [super description], self.filename, self.line];
}

- (BOOL)isEqual:(TALineBreakpoint *)object {
	if([object class] != self.class)
		return NO;
	
	if(object.line != self.line)
		return NO;
	
	if(object.filename == nil && self.filename == nil)
		return YES;
	
	if(![object.filename isEqualToString:self.filename])
		return NO;
	
	return YES;
}
@end
