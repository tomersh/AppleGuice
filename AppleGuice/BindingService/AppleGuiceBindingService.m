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
#import "AppleGuiceProtocolToClassMapper.h"

@implementation AppleGuiceBindingService {
    AppleGuiceProtocolToClassMapper* _cachedObjects;
    AppleGuiceProtocolToClassMapper* _userBoundObjects;
}

-(id) init {
    self = [super init];
    if (!self) return self;
    _cachedObjects = [[AppleGuiceProtocolToClassMapper alloc] init];
    _userBoundObjects = [[AppleGuiceProtocolToClassMapper alloc] init];
    return self;
}

-(AppleGuiceProtocolToClassMapper*) _mapperForBindingType:(appleGuiceBindingType) bindingType {
    return (bindingType == appleGuiceBindingTypeCachedBinding ? _cachedObjects : _userBoundObjects);
}

-(NSArray*) getClassesForProtocol:(Protocol*) protocol {
    NSSet* classes = [_userBoundObjects getClassesForProtocol:protocol];
    if ([classes count] > 0) {
        return [NSArray arrayWithArray:[classes allObjects]];
    }
    
    classes = [_cachedObjects getClassesForProtocol:protocol];;
    if ([classes count] > 0) {
        return [NSArray arrayWithArray:[classes allObjects]];
    }
    
    return nil;
}

- (void) setImplementation:(Class)clazz withProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType)bindingType {
    if (!clazz) return;
    [self setImplementations:@[clazz] withProtocol:protocol withBindingType:bindingType];
}

-(void) setImplementations:(NSArray*)classes withProtocol:(Protocol*)protocol withBindingType:(appleGuiceBindingType)bindingType {
    
    AppleGuiceProtocolToClassMapper* mapper = [self _mapperForBindingType:bindingType];
    [mapper setImplementations:classes withProtocol:protocol];
}

-(void) unsetImplementationOfProtocol:(Protocol*) protocol {
    if (!protocol) return;
    [_cachedObjects unsetImplementationOfProtocol:protocol];
    [_userBoundObjects unsetImplementationOfProtocol:protocol];
}

-(void) unsetAllImplementationsWithType:(appleGuiceBindingType) bindingType {
    AppleGuiceProtocolToClassMapper* mapper = [self _mapperForBindingType:bindingType];
    [mapper unsetAllImplementations];
}

-(void) setImplementationFromString:(NSString*)classAsString withProtocolAsString:(NSString*)protocolAsString withBindingType:(appleGuiceBindingType)bindingType {
    if (!classAsString) return;
    [self setImplementationsFromStrings:@[classAsString] withProtocolAsString:protocolAsString withBindingType:bindingType];
}

-(void) setImplementationsFromStrings:(NSArray*)classesAsString withProtocolAsString:(NSString*)protocolAsString withBindingType:(appleGuiceBindingType)bindingType {
    Protocol* protocol = NSProtocolFromString(protocolAsString);
    
    if (!protocol) return;
    
    NSArray* classes = [self.classGenerator safeGetClassesFromStrings:classesAsString];
    [self setImplementations:classes withProtocol:protocol withBindingType:bindingType];
}

-(void)dealloc {
    [_classGenerator release];
    [_userBoundObjects release];
    [_cachedObjects release];
    [super dealloc];
}

@end
