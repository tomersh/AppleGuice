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


#import "AppleGuiceInstanceCreator.h"
#import "AppleGuiceBindingServiceProtocol.h"
#import "AppleGuiceSettingsProviderProtocol.h"
#import "AppleGuiceSingletonRepositoryProtocol.h"
#import "AppleGuiceInjectorProtocol.h"
#import "AppleGuiceSingleton.h"
#import "AppleGuiceMockProviderProtocol.h"


@implementation AppleGuiceInstanceCreator

-(NSArray*) allInstancesForProtocol:(Protocol*) protocol {
    if (!protocol) return nil;
    
    if ([self _shouldInjectMocks]) {
        id mock = [self instanceForProtocol:protocol];
        return @[ mock ];
    }
    
    NSArray* classesForProtocol = [self.bindingService getClassesForProtocol:protocol];
    
    if (!classesForProtocol || [classesForProtocol count] == 0) return nil;
    
    NSMutableArray* instances = [[[NSMutableArray alloc] initWithCapacity:[classesForProtocol count]] autorelease];
    
    for (Class clazz in classesForProtocol) {
        id instance = [self instanceForClass:clazz];
        
        if (!instance) continue;
        
        [instances addObject:instance];
    }
    
    return [NSArray arrayWithArray:instances];
}

-(id<NSObject>) instanceForProtocol:(Protocol*) protocol {
    if (!protocol) return nil;
    
    if ([self _shouldInjectMocks]) {
        id mock = [[self.mockProvider mockForProtocol:protocol] retain];
        return [mock autorelease];
    }
    
    Class clazz = [self _classForProtocol:protocol];
    return [self instanceForClass:clazz];
}

-(id<NSObject>) instanceForClass:(Class) clazz {
    if (!clazz) return nil;
    
    id classInstance;
    
    if ([self _shouldReturnSingletonInstanceForClass:clazz]) {
        classInstance = [self singletonForClass:clazz];
    }
    else {
        classInstance = [self _createInstanceForClass:clazz];
    }
    return classInstance;
}

-(id) singletonForProtocol:(Protocol*) protocol {
    Class clazz = [self _classForProtocol:protocol];
    return [self instanceForClass:clazz];
}

-(id) singletonForClass:(Class) clazz {
    id classInstance = [self.singletonRepository instanceForClass:clazz];
    if (!classInstance) {
        if ([self _shouldInjectMocks]) {
            classInstance = [[self.mockProvider mockForClass:clazz] retain];
            [self.singletonRepository setInstance:classInstance forClass:clazz];
            [classInstance autorelease];
        }
        else {
            classInstance = [clazz alloc];
            [self.singletonRepository setInstance:classInstance forClass:clazz];
            [[classInstance init] autorelease];
            [self _injectImplementationsToInstanceIfneeded:classInstance];
        }
    }
    return classInstance;
}

-(id) _createInstanceForClass:(Class) clazz {
    id classInstance;
    
    if ([self _shouldInjectMocks]) {
        classInstance = [[self.mockProvider mockForClass:clazz] retain];
    }
    else {
        classInstance = [[clazz alloc] init];
        [self _injectImplementationsToInstanceIfneeded:classInstance];
    }
    return [classInstance autorelease];
}

-(void) _injectImplementationsToInstanceIfneeded:(id<NSObject>) classInstance {
    BOOL shouldInject = self.settingsProvider.methodInjectionPolicy == AppleGuiceMethodInjectionPolicyManual;
    if (shouldInject) {
        [self.injector injectImplementationsToInstance:classInstance];
    }
}

-(Class) _classForProtocol:(Protocol*) protocol {
    NSArray* classesForProtocol = [self.bindingService getClassesForProtocol:protocol];
    if ([classesForProtocol count] == 0) return nil;
    return [classesForProtocol firstObject];
}

-(BOOL) _shouldReturnSingletonInstanceForClass:(Class) clazz {
    return (self.settingsProvider.instanceCreateionPolicy & AppleGuiceInstanceCreationPolicySingletons) || [[self.bindingService getClassesForProtocol:@protocol(AppleGuiceSingleton)] containsObject:clazz];
}

-(BOOL) _shouldInjectMocks {
    return (self.settingsProvider.instanceCreateionPolicy & AppleGuiceInstanceCreationPolicyCreateMocks);
}

- (void)dealloc {
    [_bindingService release];
    [_settingsProvider release];
    [_singletonRepository release];
    [_injector release];
    [_mockProvider release];
    [super dealloc];
}

@end
