//
//  TAErrorResponse.h
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

typedef enum {
	//! 000 Command parsing errors
	
	// no error
	TANoErrorCode							= 0,
	
	// parse error in command
	TAParseErrorCode						= 1,
	
	// duplicate arguments in command
	TADuplicateArgumentsErrorCode			= 2,
	
	// invalid options (ie, missing a required option, invalid
	// value for a passed option, not supported feature)
	TAInvalidOptionsErrorCode				= 3,
	
	// unimplemented command
	TAUnimplementedCommandErrorCode			= 4,
	
	// Command not available (Is used for async commands. For instance
	// if the engine is in state "run" then only "break" and "status"
	// are available).
	TACommandNotAvailableErrorCode			= 5,
	
	
	//! 100 File related errors
	
	// can not open file (as a reply to a "source" command if the
	// requested source file can't be opened)
	TAOpenFileErrorCode						= 100,
	
	// stream redirect failed
	TARedirectErrorCode						= 101,
	
	// 200 Breakpoint, or code flow errors
	
	// breakpoint could not be set (for some reason the breakpoint
	// could not be set due to problems registering it)
	TABreakpointSetErrorCode				= 200,
	
	// breakpoint type not supported (for example I don't support
	// 'watch' yet and thus return this error)
	TABreakpointTypeErrorCode				= 201,
	
	// invalid breakpoint (the IDE tried to set a breakpoint on a
	// line that does not exist in the file (ie "line 0" or lines
	// past the end of the file)
	TABreakpointInvalidErrorCode			= 202,
	
	// no code on breakpoint line (the IDE tried to set a breakpoint
	// on a line which does not have any executable code. The
	// debugger engine is NOT required to return this type if it
	// is impossible to determine if there is code on a given
	// location. (For example, in the PHP debugger backend this
	// will only be returned in some special cases where the current
	// scope falls into the scope of the breakpoint to be set)).
	TABreakpointNoCodeErrorCode				= 203,
	
	// Invalid breakpoint state (using an unsupported breakpoint state
	// was attempted)
	TABreakpointInvalidStateErrorCode		= 204,
	
	// No such breakpoint (used in breakpoint_get etc. to show that
	// there is no breakpoint with the given ID)
	TABreakpointNotFoundErrorCode			= 205,
	
	// Error evaluating code (use from eval() (or perhaps
	// property_get for a full name get))
	TABreakpointEvalErrorCode				= 207,
	
	// Invalid expression (the expression used for a non-eval()
	// was invalid)
	TABreakpointInvalidExpressionErrorCode	= 208,
	
	
	//!  300 Data errors
	
	// Can not get property (when the requested property to get did
	// not exist, this is NOT used for an existing but uninitialized
	// property, which just gets the type "uninitialised" (See:
	// PreferredTypeNames)).
	TAPropertyObtainErrorCode				= 300,
	
	// Stack depth invalid (the -d stack depth parameter did not
	// exist (ie, there were less stack elements than the number
	// requested) or the parameter was < 0)
	TAStackDepthErrorCode					= 301,
	
	// Context invalid (an non existing context was requested)
	TAContextErrorCode						= 302,
	
	
	//!  900 Protocol errors
	
	// Encoding not supported
	TAEncodingErrorCode						= 900,
	
	// An internal exception in the debugger occurred
	TAInternalErrorCode						= 998,
	
	// Unknown error
	TAUnknownErrorCode						= 999
} TAErrorCode;




@interface TAErrorResponse : TAResponse
@property (nonatomic, readonly) TAErrorCode code;
@property (nonatomic, readonly) NSString *message;
@end
