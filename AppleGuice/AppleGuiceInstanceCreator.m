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
#import "AppleGuiceProtocolLocatorProtocol.h"
#import "AppleGuiceSettingsProviderProtocol.h"
#import "AppleGuiceSingletonRepositoryProtocol.h"
#import "AppleGuiceInjectorProtocol.h"
#import "AppleGuiceSingleton.h"


@implementation AppleGuiceInstanceCreator {
    id<AppleGuiceProtocolLocatorProtocol> _ioc_protocolLocator;
    id<AppleGuiceSingletonRepositoryProtocol> _ioc_singletonRepository;
    id<AppleGuiceSettingsProviderProtocol> _ioc_settingsProvider;
    id<AppleGuiceInjectorProtocol> _ioc_injector;
}

@synthesize protocolLocator = _ioc_protocolLocator, settingsProvider = _ioc_settingsProvider, singletonRepository = _ioc_singletonRepository, injector = _ioc_injector;


-(NSArray*) allInstancesForProtocol:(Protocol*) protocol {
    if (!protocol) return nil;

    NSArray* classesForProtocol = [self.protocolLocator getAllClassesByProtocolType:protocol];
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

    NSArray* classesForProtocol = [self.protocolLocator getAllClassesByProtocolType:protocol];
    if (!classesForProtocol || [classesForProtocol count] == 0) return nil;
    Class clazz = [classesForProtocol objectAtIndex:0];
    return [self instanceForClass:clazz];
}

-(id<NSObject>) instanceForClass:(Class) clazz {
    if (!clazz) return nil;

    id classInstance;
    if ([self _shouldReturnSingletonInstanceForClass:clazz]) {
        classInstance = [self _singletonForClass:clazz];
    }
    else {
        classInstance = [self _newInstanceForClass:clazz];
    }
    return classInstance;
}

-(id) _singletonForClass:(Class) clazz {
    if (![self.singletonRepository hasInstanceForClass:clazz]) {
        id classInstance = [self _newInstanceForClass:clazz];
        [self.singletonRepository setInstance:classInstance forClass:clazz];
        return classInstance;
    }
    return [self.singletonRepository instanceForClass:clazz];
}

-(id) _newInstanceForClass:(Class) clazz {
    id classInstance = [[[clazz alloc] init] autorelease];
    if (self.settingsProvider.methodInjectionPolicy == AppleGuiceMethodInjectionPolicyManual) {
        [self.injector injectImplementationsToInstance:classInstance];
    }
    return classInstance;
}

-(BOOL) _shouldReturnSingletonInstanceForClass:(Class) clazz {
    return (self.settingsProvider.instanceCreateionPolicy & AppleGuiceInstanceCreationPolicySingletons) || [[self.protocolLocator getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)] containsObject:clazz];
}

- (void)dealloc {
    [_ioc_protocolLocator release];
    [_ioc_settingsProvider release];
    [_ioc_singletonRepository release];
    [_ioc_injector release];
    [super dealloc];
}

@end