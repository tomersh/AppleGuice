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
#import <objc/runtime.h>
#import "AppleGuiceInvocationProxy.h"
#import "AppleGuiceInstanceCreatorProtocol.h"
#import "AppleGuiceInjectableImplementationNotFoundException.h"
#import "AppleGuiceOptional.h"

@implementation AppleGuiceInjector


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
        return [self _getValueForIvar:ivar withName:ivarName];
    };
    
    if ([self _shouldLazyLoadObjects]) {
        id ivarValue = [[AppleGuiceInvocationProxy alloc] autorelease];
        ((AppleGuiceInvocationProxy*)ivarValue).createInstanceBlock = createInstanceBlock;
        [instance setValue:ivarValue forKey:ivarName];
        return;
    }
    
    id ivarValue = createInstanceBlock();
    if (ivarValue != nil) {
        [instance setValue:ivarValue forKey:ivarName];
    }
}

-(BOOL) _shouldLazyLoadObjects {
    return (self.settingsProvider.instanceCreateionPolicy & AppleGuiceInstanceCreationPolicyLazyLoad);
}

-(id) _getValueForIvar:(Ivar)ivar withName:(NSString*) ivarName {
    
    const char* ivarTypeEncoding = ivar_getTypeEncoding(ivar);
    
    if ([self _isPrimitiveType:ivarTypeEncoding]) {
        return nil;
    }
    
    NSString* className = [self _classNameFromType:ivarTypeEncoding];
    
    if ([self _isProtocol:className]) {
        NSString* protocolName = [self _protocolNameFromType:className];
        return [self _valueForIvarNamed:ivarName withProtocolNamed:protocolName];
    }
    
    if ([self _isArray:ivarTypeEncoding]) {
        return [self _allValuesForIvarNamed:ivarName];
    }
    
    return [self _valueForIvarNamed:ivarName withClassNamed:className];
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

-(NSArray*) _allValuesForIvarNamed:(NSString*) ivarName {
    NSArray* ivarValue = nil;
    NSString* protocolNameFromIvarName = [ivarName substringFromIndex:[self.settingsProvider.iocPrefix length]];

    ivarValue = [self.instanceCreator allInstancesForProtocol:NSProtocolFromString(protocolNameFromIvarName)];
        //array can be nil.

    return ivarValue;
}

-(id) _valueForIvarNamed:(NSString*) ivarName withProtocolNamed:(NSString*) protocolName {
    id ivarValue = nil;
    Protocol* protocol = NSProtocolFromString(protocolName);
    
    ivarValue = [self.instanceCreator instanceForProtocol:protocol];
    
    if (!ivarValue && [self _shouldThrowOnFailedInjection:protocol]) {
        @throw [AppleGuiceInjectableImplementationNotFoundException exceptionWithIvarName:ivarName andProtocolName:protocolName];
    }
    return ivarValue;
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

-(NSString*) _protocolNameFromType:(NSString*) iVarType {
    //<xxx>
    return [[iVarType substringFromIndex:1] substringToIndex:[iVarType length] - 2];
}

-(NSString*) _classNameFromType:(const char*) typeEncoding {
    //@"xxx"
    size_t objectNameLength = strlen(typeEncoding) - 2;
    char* classNameAsCString = malloc(sizeof(char) * strlen(typeEncoding));
    strcpy( classNameAsCString, typeEncoding + (sizeof(char) * 2));
    classNameAsCString[objectNameLength - 1] = '\0';
    NSString* classNameAsNSString = [NSString stringWithUTF8String:classNameAsCString];
    free(classNameAsCString);
    return classNameAsNSString;
}

-(BOOL) _isPrimitiveType:(const char*) ivarTypeEncoding {
    const char* objectEncoding = @encode(id);
    return strncmp(ivarTypeEncoding, objectEncoding, strlen(objectEncoding)) != 0;
}

-(BOOL) _isArray:(const char*) ivarTypeEncoding {
    const char* arrayEncoding = "@\"NSArray\"\0";
    return strcmp(ivarTypeEncoding, arrayEncoding) == 0;
}

- (void) dealloc {
    [_settingsProvider release];
    [_instanceCreator release];
    [super dealloc];
}

@end