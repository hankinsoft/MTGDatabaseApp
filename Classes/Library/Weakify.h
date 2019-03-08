//
//  weakify.h
//  HSCore
//
//  Created by kylehankinson on 2018-04-13.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#ifndef weakify_h
#define weakify_h

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
if(nil == var) { return; } \
_Pragma("clang diagnostic pop")

#define strongify_return(var,b) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
if(nil == var) { return (b); } \
_Pragma("clang diagnostic pop")

#endif /* weakify_h */
