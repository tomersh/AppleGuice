//
//  TheWrapper.m
//
//  Created by Tomer Shiri on 1/10/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "TheWrapper.h"
#import <objc/runtime.h>

#define va_list_arg(__name) id __name = va_arg(args, id);

// Hash combining method from http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

@interface WrappedFunctionData : NSObject

@property (nonatomic, copy) void (^preRunBlock)(id<NSObject> zelf,id firstArg, ...);
@property (nonatomic, copy) id (^postRunBlock)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...);
@property (nonatomic, assign) IMP originalImplementation;
@end

@implementation WrappedFunctionData {
    void (^_preRunBlock)(id<NSObject> zelf,id firstArg, ...);
    id (^_postRunBlock)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...);
    IMP _originalImplementation;
}

@synthesize preRunBlock = _preRunBlock, postRunBlock = _postRunBlock, originalImplementation = _originalImplementation;

-(id) initWithOriginalImplementation:(IMP) originalImplementation andPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock andPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock {
    self = [super init];
    if (!self) return self;
    self.originalImplementation = originalImplementation;
    self.preRunBlock = preRunblock;
    self.postRunBlock = postRunBlock;
    return self;
}

-(void)dealloc {
    self.preRunBlock = nil;
    self.postRunBlock = nil;
    self.originalImplementation = nil;
    [super dealloc];
}

@end

@implementation TheWrapper

static NSMutableDictionary* _wrappedFunctions;

+(id) init {
    return nil;
}

+(void)initialize {
    _wrappedFunctions = [[NSMutableDictionary alloc] init];
}

+(BOOL) isInstance:(id) object {
    return class_isMetaClass(object_getClass(object));
}

+(void) addWrapperto:(id<NSObject>) target andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock {
    [TheWrapper addWrapperto:target andSelector:selector withPreRunBlock:preRunblock andPostRunBlock:nil];
}

+(void) addWrapperto:(id<NSObject>) target andSelector:(SEL) selector withPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock {
    [TheWrapper addWrapperto:target andSelector:selector withPreRunBlock:nil andPostRunBlock:postRunBlock];
}

+(void) addWrapperto:(id<NSObject>) target andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock andPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock {
    
    Class clazz = [TheWrapper isInstance:target] ? [target class] : target;
    [TheWrapper addWrappertoClass:clazz andSelector:selector withPreRunBlock:preRunblock andPostRunBlock:postRunBlock];
}


+(void) addWrappertoClass:(Class) clazz andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock {
    [TheWrapper addWrappertoClass:clazz andSelector:selector withPreRunBlock:preRunblock andPostRunBlock:nil];
}

+(void) addWrappertoClass:(Class) clazz andSelector:(SEL) selector withPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock {
    [TheWrapper addWrappertoClass:clazz andSelector:selector withPreRunBlock:nil andPostRunBlock:postRunBlock];
}


+(void) addWrappertoClass:(Class) clazz andSelector:(SEL) selector withPreRunBlock:(void (^)(id<NSObject> zelf,id firstArg, ...)) preRunblock andPostRunBlock:(id (^)(id<NSObject> zelf, id functionReturnValue,id firstArg, ...)) postRunBlock {
    
    Method originalMethod = class_getInstanceMethod(clazz, selector);
    
    if(originalMethod == nil) {
        originalMethod = class_getClassMethod(clazz, selector);
    }
    
    IMP originaImplementation = method_getImplementation(originalMethod);
    
    WrappedFunctionData* wrappedFunctionData = [_wrappedFunctions objectForKey:[TheWrapper getStoredKeyForClass:clazz andSelector:selector]];
    
    BOOL isAlreadyWrapped = wrappedFunctionData != nil;
    
    if(isAlreadyWrapped) {
        wrappedFunctionData.preRunBlock = preRunblock;
        wrappedFunctionData.postRunBlock = postRunBlock;
    }
    else {
        wrappedFunctionData = [[WrappedFunctionData alloc] initWithOriginalImplementation:originaImplementation andPreRunBlock:preRunblock andPostRunBlock:postRunBlock];
        [_wrappedFunctions setObject:wrappedFunctionData forKey:[TheWrapper getStoredKeyForClass:clazz andSelector:selector]];
        [wrappedFunctionData release];
    }
    
    if(class_addMethod(clazz, selector, (IMP)wrapperFunction, method_getTypeEncoding(originalMethod))) {
        method_setImplementation(originalMethod, (IMP)wrapperFunction);
    }
    else {
        class_replaceMethod(clazz, selector, (IMP)wrapperFunction, method_getTypeEncoding(originalMethod));
    }
}

+(void) removeWrapperFrom:(id<NSObject>) target andSelector:(SEL) selector {
    Class clazz = [TheWrapper isInstance:target] ? [target class] : target;
    [TheWrapper removeWrapperFromClass:clazz andSelector:selector];
}

+(void) removeWrapperFromClass:(Class) clazz andSelector:(SEL) selector {
    [TheWrapper addWrappertoClass:clazz andSelector:selector withPreRunBlock:nil andPostRunBlock:nil];
}

+ (NSNumber*)getStoredKeyForClass:(Class)clazz andSelector:(SEL)selector
{
    NSUInteger hash = NSUINTROTATE([clazz hash], NSUINT_BIT / 2) ^ [[NSString stringWithUTF8String:sel_getName(selector)] hash];
    return [NSNumber numberWithUnsignedInteger:hash];
}

+ (WrappedFunctionData*) getFunctionData:(Class) clazz andSelector:(SEL) selector
{
    while(clazz)
    {
        WrappedFunctionData* wrappedFunctionData = [_wrappedFunctions objectForKey:[TheWrapper getStoredKeyForClass:clazz andSelector:selector]];
        if (wrappedFunctionData) return wrappedFunctionData;
        clazz = class_getSuperclass(clazz);
    }
    return nil;
}

static id wrapperFunction(id self, SEL _cmd, id firstArg, ...)
{
    id returnValue = nil;
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    va_list args;
    va_list arguments;
    
    va_start(args, firstArg);
    va_copy(arguments, args);
    
    WrappedFunctionData* wrappedFunctionData = [TheWrapper getFunctionData:[self class] andSelector:_cmd];
    
    if (!wrappedFunctionData) {
        [(NSObject*)self doesNotRecognizeSelector:_cmd];
        return self;
    }
    
    if (wrappedFunctionData.preRunBlock) {
        wrappedFunctionData.preRunBlock(self, firstArg, arguments);
    }
    
    //There must be a better way to do this...
    id a0 = firstArg; va_list_arg(a1); va_list_arg(a2); va_list_arg(a3); va_list_arg(a4);
    va_list_arg(a5); va_list_arg(a6); va_list_arg(a7); va_list_arg(a8); va_list_arg(a9);
    va_list_arg(a10); va_list_arg(a11); va_list_arg(a12); va_list_arg(a13); va_list_arg(a14);
    va_list_arg(a15); va_list_arg(a16); va_list_arg(a17); va_list_arg(a18); va_list_arg(a19);
    va_list_arg(a20); va_list_arg(a21); va_list_arg(a22); va_list_arg(a23); va_list_arg(a24);
    va_list_arg(a25); va_list_arg(a26); va_list_arg(a27); va_list_arg(a28); va_list_arg(a29);
    va_list_arg(a30); va_list_arg(a31); va_list_arg(a32); va_list_arg(a33); va_list_arg(a34);
    va_list_arg(a35); va_list_arg(a36); va_list_arg(a37); va_list_arg(a38); va_list_arg(a39);
    va_list_arg(a40); va_list_arg(a41); va_list_arg(a42); va_list_arg(a43); va_list_arg(a44);
    va_list_arg(a45); va_list_arg(a46); va_list_arg(a47); va_list_arg(a48); va_list_arg(a49);
    va_list_arg(a50); va_list_arg(a51); va_list_arg(a52); va_list_arg(a53); va_list_arg(a54);
    va_list_arg(a55); va_list_arg(a56); va_list_arg(a57); va_list_arg(a58); va_list_arg(a59);
    va_list_arg(a60); va_list_arg(a61); va_list_arg(a62); va_list_arg(a63); va_list_arg(a64);
    va_list_arg(a65); va_list_arg(a66); va_list_arg(a67); va_list_arg(a68); va_list_arg(a69);
    va_list_arg(a70); va_list_arg(a71); va_list_arg(a72); va_list_arg(a73); va_list_arg(a74);
    va_list_arg(a75); va_list_arg(a76); va_list_arg(a77); va_list_arg(a78); va_list_arg(a79);
    va_list_arg(a80); va_list_arg(a81); va_list_arg(a82); va_list_arg(a83); va_list_arg(a84);
    va_list_arg(a85); va_list_arg(a86); va_list_arg(a87); va_list_arg(a88); va_list_arg(a89);
    va_list_arg(a90); va_list_arg(a91); va_list_arg(a92); va_list_arg(a93); va_list_arg(a94);
    va_list_arg(a95); va_list_arg(a96); va_list_arg(a97); va_list_arg(a98); va_list_arg(a99);
    
    IMP originalImplementation = wrappedFunctionData.originalImplementation;
    
    returnValue = originalImplementation(self, _cmd, a0, a1, a2 ,a3 ,a4, a5, a6, a7, a8, a9, a10, a11, a12 ,a13 ,a14, a15, a16, a17, a18, a19, a20, a21, a22 ,a23 ,a24, a25, a26, a27, a28, a29, a30, a31, a32 ,a33 ,a34, a35, a36, a37, a38, a39, a40, a41, a42 ,a43 ,a44, a45, a46, a47, a48, a49, a50, a51, a52 ,a53 ,a54, a55, a56, a57, a58, a59, a60, a61, a62 ,a63 ,a64, a65, a66, a67, a68, a69, a70, a71, a72 ,a73 ,a74, a75, a76, a77, a78, a79, a80, a81, a82 ,a83 ,a84, a85, a86, a87, a88, a89, a90, a91, a92 ,a93 ,a94, a95, a96, a97, a98, a99);
    
    if (wrappedFunctionData.postRunBlock != nil) {
        returnValue = wrappedFunctionData.postRunBlock(self, returnValue, firstArg, arguments);
    }
    
    va_end(arguments);
    va_end(args);
    
    [pool drain];
    return returnValue;
}

@end
