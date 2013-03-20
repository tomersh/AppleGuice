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

#import "AppleGuiceBindingService.h"

@implementation AppleGuiceBindingService {
    NSMutableDictionary* _cachedObjects;
    NSMutableDictionary* _userBoundObjects;
}

-(id) init {
    self = [super init];
    if (!self) return self;
    _cachedObjects = [[NSMutableDictionary alloc] init];
    _userBoundObjects = [[NSMutableDictionary alloc] init];
    return self;
}

-(NSArray*) getClassesForProtocol:(Protocol*) protocol {
    NSMutableSet* classes = [self _getClassesForProtocol:protocol withBindingType:appleGuiceBindingTypeUserBinding];
    if (classes) {
        return [NSArray arrayWithArray:[classes allObjects]];
    }
    
    classes = [self _getClassesForProtocol:protocol withBindingType:appleGuiceBindingTypeCachedBinding];
    if (classes) {
        return [NSArray arrayWithArray:[classes allObjects]];
    }
    
    return nil;
}

-(NSMutableSet*) _getClassesForProtocol:(Protocol*) protocol withBindingType:(appleGuiceBindingType) bindingType {
    if (bindingType == appleGuiceBindingTypeCachedBinding)
        return [_cachedObjects objectForKey:[self _storageKeyForProtocol:protocol]];
    return [_userBoundObjects objectForKey:[self _storageKeyForProtocol:protocol]];
}

-(id<NSCopying>) _storageKeyForProtocol:(Protocol*) protocol {
    return NSStringFromProtocol(protocol);
}

- (void) setImplementation:(Class)clazz withProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType)bindingType {
    [self setImplementations:@[clazz] withProtocol:protocol withBindingType:bindingType];
}

-(void) setImplementations:(NSArray*)classes withProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType)bindingType {
    if (!protocol || !classes) return;
    NSMutableSet* boundClasses = [self _getClassesForProtocol:protocol withBindingType:bindingType];
    if (!boundClasses) {
        boundClasses = [NSMutableSet set];
    }
    [boundClasses addObjectsFromArray:classes];
    
    [self _bindClasses:boundClasses toProtocol:protocol withBindingType:bindingType];
}

-(void) _bindClasses:(NSMutableSet*)classesSet toProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType)bindingType {
    if (bindingType == appleGuiceBindingTypeUserBinding) {
        [_userBoundObjects setObject:classesSet forKey:[self _storageKeyForProtocol:protocol]];
    }
    if (bindingType == appleGuiceBindingTypeCachedBinding) {
        [_cachedObjects setObject:classesSet forKey:[self _storageKeyForProtocol:protocol]];
    }
}

-(void) unsetImplementationOfProtocol:(Protocol*) protocol {
    [_cachedObjects removeObjectForKey:[self _storageKeyForProtocol:protocol]];
    [_userBoundObjects removeObjectForKey:[self _storageKeyForProtocol:protocol]];
}

-(void) unsetAllImplementationsWithType:(appleGuiceBindingType) bindingType {
    if (bindingType == appleGuiceBindingTypeUserBinding) {
        [_userBoundObjects removeAllObjects];
    }
    if (bindingType == appleGuiceBindingTypeCachedBinding) {
        [_cachedObjects removeAllObjects];
    }
}

-(void) setImplementationFromString:(NSString*)classAsString withProtocolAsString:(NSString*)protocolAsString withBindingType:(appleGuiceBindingType)bindingType {
    [self setImplementationsFromStrings:@[classAsString] withProtocolAsString:protocolAsString withBindingType:bindingType];
}

-(void) setImplementationsFromStrings:(NSArray*)classesAsString withProtocolAsString:(NSString*)protocolAsString withBindingType:(appleGuiceBindingType)bindingType {
    Protocol* protocol = NSProtocolFromString(protocolAsString);
    
    if (!protocol) return;
    
    NSMutableArray* classes = [NSMutableArray arrayWithCapacity:[classesAsString count]];
    for (NSString* className in classesAsString) {
        Class clazz = NSClassFromString(className);
        if (clazz) {
            [classes addObject:clazz];
        }
    }
    [self setImplementations:classes withProtocol:protocol withBindingType:bindingType];
}

-(void)dealloc {
    [_userBoundObjects release];
    [_cachedObjects release];
    [super dealloc];
}

@end
