//
//  Utilities.h
//  Matchismo_stage2
//
//  Created by Olga on 29/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#ifndef Matchismo_stage2_Utilities_h
#define Matchismo_stage2_Utilities_h


#define UnavailableMacro(msg) __attribute__((unavailable(msg)))

#define SYSASSERT(cond, msg) NSAssert(cond, @"Assert occured at %@ line: %d, with message: %@", NSStringFromSelector(_cmd), __LINE__, msg)

/*
#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException \
                                                      reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__ \
                                                    userInfo:nil]
*/

#define mustOverride() @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%s must be overridden in a subclass/category", __PRETTY_FUNCTION__] userInfo:nil]

#endif
