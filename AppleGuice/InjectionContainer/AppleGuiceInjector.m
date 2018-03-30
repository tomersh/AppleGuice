//Copyright 2013 Tomer Shiri appleguice@shiri.info
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

#import "AppleGuiceInjector.h"
#import "AppleGuiceSettingsProviderProtocol.h"
#import "AppleGuiceInvocationProxy.h"
#import "AppleGuiceInstanceCreatorProtocol.h"
#import "AppleGuiceSwiftProtocolDemanglerProtocol.h"
#import "AppleGuiceInjectableImplementationNotFoundException.h"
#import "AppleGuiceOptional.h"
#import "AppleGuiceSingleton.h"
#import "AppleGuiceLazyLoad.h"
#import <objc/runtime.h>
#import "IvarAccess.h"

@implementation AppleGuiceInjector

static NSString* appleGuiceSingletonProtocolName;
static NSString* appleGuiceLazyLoadProtocolName;
static NSString* appleGuiceOptionalProtocolName;
static NSSet<NSString*>* appleGuiceInstanceFlags;
static const char * swiftClassVarPivotSubstring = ",N,&,V";

+(void)initialize {
    appleGuiceSingletonProtocolName = [NSStringFromProtocol(@protocol(AppleGuiceSingleton)) retain];
    appleGuiceLazyLoadProtocolName = [NSStringFromProtocol(@protocol(AppleGuiceLazyLoad)) retain];
    appleGuiceOptionalProtocolName = [NSStringFromProtocol(@protocol(AppleGuiceOptional)) retain];
    appleGuiceInstanceFlags = [[NSSet setWithObjects: appleGuiceSingletonProtocolName, appleGuiceLazyLoadProtocolName, appleGuiceOptionalProtocolName, nil] retain];
}

-(void) injectImplementationsToInstance:(id<NSObject>) classInstance {
    if (!classInstance) return;
    Class clazz = [classInstance class];
    while (clazz) {
        [self _injectImplementationsToInstance:classInstance class:clazz];
        clazz = class_getSuperclass(clazz);
    }
}

-(void) _injectImplementationsToInstance:(id <NSObject>)classInstance class:(Class) clazz {
    unsigned int numberOfIvars = 0;
    Ivar* iVars = class_copyIvarList([clazz class], &numberOfIvars);
    for (int i = 0; i < numberOfIvars; ++i) {
        Ivar ivar = iVars[i];
        
        [self _setValueForIvar:ivar inObjectInstance:classInstance];
    }
    free(iVars);
}

-(void) _setValueForIvar:(Ivar)ivar inObjectInstance:(id) instance {
    
    NSString* ivarName = [self _getIvarName:ivar];
    
    if (![self _isIOCIvar:ivarName]) return;
    
    id (^createInstanceBlock)(void) = ^id(void) {
        return [self _getValueForIvar:ivar withName:ivarName class:[instance class]];
    };
    
    id ivarValue;
    
    if ([self _shouldLazyLoadObjects]) {
        AppleGuiceInvocationProxy* ivarProxy = [[AppleGuiceInvocationProxy alloc] autorelease];
        ivarProxy.createInstanceBlock = createInstanceBlock;
        ivarValue = ivarProxy;
    }
    else {
        ivarValue = createInstanceBlock();
    }
    
    if (ivarValue) {
        [instance setValue:ivarValue forKey:ivarName];
    }
}

-(BOOL) _shouldLazyLoadObjects {
    return (self.settingsProvider.instanceCreateionPolicy & AppleGuiceInstanceCreationPolicyLazyLoad);
}

// we support the following flavors:
// clazz ioc_xx
// id<injectable> ioc_xx
// id<injectable, appleguicesingleton, etc> ioc_xx
// NSArray ioc_injectable
-(id) _getValueForIvar:(Ivar)ivar withName:(NSString*) ivarName class:(Class)clazz {
    
    char* ivarTypeEncoding = (char *)ivar_getTypeEncodingSwift(ivar, clazz);
    if ([self _isPrimitiveType:ivarTypeEncoding]) {
        return nil;
    }
    
    NSString* className = [self _classNameFromType:ivarTypeEncoding];
    
    if ([self _isProtocol:className]) {
        NSMutableSet<NSString*>* protocolNames = [self _protocolNamesFromType:className];
        
        BOOL isSingleton = [protocolNames containsObject:appleGuiceSingletonProtocolName];
        BOOL isOptional = [protocolNames containsObject:appleGuiceOptionalProtocolName];
        BOOL shouldLazyLoad = [protocolNames containsObject:appleGuiceLazyLoadProtocolName];
        if ([protocolNames count] > 1) {
            [protocolNames minusSet:appleGuiceInstanceFlags];
        }
        NSString* protocolNameToInject = [protocolNames anyObject];
        
        return [self _valueForIvarNamed:ivarName withProtocolNamed:protocolNameToInject forceSingleton:isSingleton shouldLazyLoad:shouldLazyLoad isOptional:isOptional];
    }
    
    if ([self _isArray:className]) {
        return [self _allValuesForIvarNamed:ivarName];
    }
    
    return [self _valueForIvarNamed:ivarName withClassNamed:className];
}

-(NSArray*) _allValuesForIvarNamed:(NSString*) ivarName {
    NSArray* ivarValue = nil;
    NSString* protocolNameFromIvarName = [ivarName substringFromIndex:[self.settingsProvider.iocPrefix length]];
    
    ivarValue = [self.instanceCreator allInstancesForProtocol:NSProtocolFromString(protocolNameFromIvarName)];
    //array can be nil.
    
    return ivarValue;
}

-(id) _valueForIvarNamed:(NSString*) ivarName withClassNamed:(NSString*) className {
    id ivarValue = nil;
    Class clazz = NSClassFromString(className);
    
    ivarValue = [self.instanceCreator instanceForClass:clazz];
    
    if (!ivarValue) {
        @throw [AppleGuiceInjectableImplementationNotFoundException exceptionWithIvarName:ivarName andClassName:className];
    }
    return ivarValue;
}

-(id) _valueForIvarNamed:(NSString*) ivarName withProtocolNamed:(NSString*) protocolName forceSingleton:(BOOL) forceSingleton shouldLazyLoad:(BOOL) shouldLazyLoad isOptional:(BOOL) isOptional {
    
    id (^createInstanceBlock)(void) = ^id(void) {
        
        Protocol* protocol = NSProtocolFromString(protocolName);
        
        id ivarValue = nil;
        if (forceSingleton) {
            ivarValue = [self.instanceCreator singletonForProtocol:protocol];
        }
        else {
            ivarValue = [self.instanceCreator instanceForProtocol:protocol];
        }
        
        if (!ivarValue && !isOptional && [self _shouldThrowOnFailedInjection:protocol]) {
            @throw [AppleGuiceInjectableImplementationNotFoundException exceptionWithIvarName:ivarName andProtocolName:protocolName];
        }
        return ivarValue;
    };
    
    if (shouldLazyLoad) {
        AppleGuiceInvocationProxy* ivarProxy = [AppleGuiceInvocationProxy alloc];
        ivarProxy.createInstanceBlock = createInstanceBlock;
        return [ivarProxy autorelease];
    }
    
    return createInstanceBlock();
}

-(BOOL) _shouldThrowOnFailedInjection:(Protocol*) protocol {
    return protocol
    && self.settingsProvider.implementationAvailabilityPolicy != AppleGuiceImplementationAvailabilityPolicyOptional
    && !protocol_conformsToProtocol(protocol, @protocol(AppleGuiceOptional));
}

-(NSString*) _getIvarName:(Ivar) iVar {
    return [NSString stringWithUTF8String:ivar_getName(iVar)];
}

-(BOOL) _isIOCIvar:(NSString*) iVarName {
    return [iVarName hasPrefix:self.settingsProvider.iocPrefix];
}

-(BOOL) _isProtocol:(NSString*) iVarType {
    if (!iVarType) return NO;
    NSUInteger leftParenPos = [iVarType rangeOfString:@"<"].location;
    NSUInteger rightParenPos = [iVarType rangeOfString:@">"].location;
    return  leftParenPos != NSNotFound && rightParenPos != NSNotFound && leftParenPos < rightParenPos;
}

-(NSMutableSet<NSString*>*) _protocolNamesFromType:(NSString*) iVarType {
    //<xxx><yyy>
    NSUInteger lastClosingBracketIndex = [iVarType rangeOfString:@">" options:NSBackwardsSearch].location;
    NSArray *protocolArr = [[[iVarType substringFromIndex:1] substringToIndex:lastClosingBracketIndex - 1] componentsSeparatedByString:@"><"];
    NSMutableSet *mutableSet = [NSMutableSet set];
    
    for (NSString *protocolName in protocolArr) {
        if ([self.swiftProtocolDemangler shouldDemangleProtocolWithName:protocolName]) {
            protocolName = [self.swiftProtocolDemangler demangledSwiftProtocol:protocolName];
        }
        [mutableSet addObject:protocolName];
    }
    
    return mutableSet;
}

-(NSString*) _classNameFromType:(char*) typeEncoding {
    //"@\"_TtC19AppleGuiceUnitTests21SwiftClassWithNoIvars\",N,&,V_test_injectableObject"
    if (strstr(typeEncoding, swiftClassVarPivotSubstring) != NULL) {
        typeEncoding = [self _removeVarNameIfNeeded:typeEncoding pivot:(char *)swiftClassVarPivotSubstring];
    }
    //@"xxx"
    size_t objectNameLength = strlen(typeEncoding) - 2;
    char* classNameAsCString = malloc(sizeof(char) * strlen(typeEncoding));
    strcpy( classNameAsCString, typeEncoding + (sizeof(char) * 2));
    classNameAsCString[objectNameLength - 1] = '\0';
    NSString* classNameAsNSString = [NSString stringWithUTF8String:classNameAsCString];
    free(classNameAsCString);
    return classNameAsNSString;
}

- (char *)_removeVarNameIfNeeded:(char*) typeEncoding pivot:(char *)pivot {
    NSString *pivotAsNSString = [NSString stringWithUTF8String:pivot];
    NSString* typeEncodingAsNSString = [NSString stringWithUTF8String:typeEncoding];
    if (![typeEncodingAsNSString containsString:pivotAsNSString]) {
        return typeEncoding;
    }
    typeEncodingAsNSString = [typeEncodingAsNSString componentsSeparatedByString:pivotAsNSString][0];
    char *normalizedTypeEncoding = (char *)[typeEncodingAsNSString UTF8String];
    return normalizedTypeEncoding;
}

-(BOOL) _isPrimitiveType:(const char*) ivarTypeEncoding {
    const char* objectEncoding = @encode(id);
    return strncmp(ivarTypeEncoding, objectEncoding, strlen(objectEncoding)) != 0;
}

-(BOOL) _isArray:(NSString *) ivarType {
    return [ivarType isEqualToString:@"NSArray"];
}

- (void) dealloc {
    [_settingsProvider release];
    [_instanceCreator release];
    [_swiftProtocolDemangler release];
    [super dealloc];
}

@end
