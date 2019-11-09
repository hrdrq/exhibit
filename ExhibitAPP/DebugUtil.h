//
//  DebugUtil.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifndef ExhibitAPP_DebugUtil_h
#define ExhibitAPP_DebugUtil_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#   define CHECK_NIL(name) \
if (nil == (name)) \
{   \
    DLog(@"Why this is nil"); \
    assert(0);\
}

# define CHECK_VALUE(value, name) \
if ((value) == (name)) \
{ \
    DLog(@"two value is different"); \
    assert(0); \
}

# define CHECK_STRING_NOT_EMPTY(name) \
if (FALSE == [(NSString*)(name) isEqualToString:@""]) \
{ \
    DLog(@"should not e empty"); \
    assert(0); \
}

#define CHECK_NOT_ENTER_HERE \
{ \
    DLog(@"should not enter here"); \
    assert(0); \
}

#endif
