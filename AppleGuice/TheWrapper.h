//
//  TheWrapper.h
//
//  Created by Tomer Shiri on 1/10/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

@interface TheWrapper : NSObject

+(void) addWrapperto:(id<NSObject>) target andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock;
+(void) addWrapperto:(id<NSObject>) target andSelector:(SEL) selector withPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock;
+(void) addWrapperto:(id<NSObject>) target andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock andPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock;

+(void) addWrappertoClass:(Class) clazz andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock;
+(void) addWrappertoClass:(Class) clazz andSelector:(SEL) selector withPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock;
+(void) addWrappertoClass:(Class) clazz andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock andPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock;

+(void) removeWrapperFrom:(id<NSObject>) target andSelector:(SEL) selector;
+(void) removeWrapperFromClass:(Class) clazz andSelector:(SEL) selector;

@end
