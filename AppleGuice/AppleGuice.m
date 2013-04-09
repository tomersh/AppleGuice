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

#import "AppleGuice.h"

#import "AppleGuiceBindingService.h"
#import "AppleGuiceAutoInjector.h"
#import "AppleGuiceInjector.h"
#import "AppleGuiceProtocolLocator.h"
#import "AppleGuiceSettingsProvider.h"
#import "AppleGuiceSingletonRepository.h"
#import "AppleGuiceBindingBootstrapper.h"
#import "AppleGuiceInstanceCreator.h"

@implementation AppleGuice

static id<AppleGuiceBindingServiceProtocol> bindingService;
static id<AppleGuiceInjectorProtocol> injector;
static id<AppleGuiceProtocolLocatorProtocol> protocolLocator;
static id<AppleGuiceSingletonRepositoryProtocol> singletonRepository;
static id<AppleGuiceSettingsProviderProtocol> settingsProvider;
static id<AppleGuiceInstanceCreatorProtocol> instanceCreator;
static id<AppleGuiceBindingBootstrapperProtocol> bootstrapper;

+(void)initialize {

    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    bindingService = [[AppleGuiceBindingService alloc] init];
    protocolLocator = [[AppleGuiceProtocolLocator alloc] init];
    injector = [[AppleGuiceInjector alloc] init];
    singletonRepository = [[AppleGuiceSingletonRepository alloc] init];
    instanceCreator = [[AppleGuiceInstanceCreator alloc] init];
    bootstrapper = [[AppleGuiceBindingBootstrapper alloc] init];

    protocolLocator.bindingService = bindingService;

    instanceCreator.protocolLocator = protocolLocator;
    instanceCreator.settingsProvider = settingsProvider;
    instanceCreator.injector = injector;
    instanceCreator.singletonRepository = singletonRepository;

    injector.settingsProvider = settingsProvider;
    injector.instanceCreator = instanceCreator;

    bootstrapper.bindingService = bindingService;

    [AppleGuiceAutoInjector setInjector:injector];
    
    [protocolLocator setFilterProtocol:@protocol(AppleGuiceInjectable)];
}

#pragma mark - Bootstrap

+(void) startService {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyPreCompile];
}

+(void) startServiceWithImplementationDiscoveryPolicy:(AppleGuiceImplementationDiscoveryPolicy) implementationDiscoveryPolicy {
    switch (implementationDiscoveryPolicy) {
        case AppleGuiceImplementationDiscoveryPolicyRuntime:
            [protocolLocator bootstrapAutomaticImplementationDiscovery];
            break;
        case AppleGuiceImplementationDiscoveryPolicyPreCompile:
            [bootstrapper bootstrap];
            break;
        case AppleGuiceImplementationDiscoveryPolicyNoAutoDiscovery:
        default:
            break;
    }
    [AppleGuice _changeAutoInjectorStateIfNeeded];
}

#pragma mark - Injection

+(id<NSObject>) instanceForClass:(Class) clazz {
    return [instanceCreator instanceForClass:clazz];
}

+(id<NSObject>) instanceForProtocol:(Protocol*) protocol {
    return [instanceCreator instanceForProtocol:protocol];
}
+(NSArray*) allInstancesForProtocol:(Protocol*) protocol {
    return [instanceCreator allInstancesForProtocol:protocol];
}

+(void) injectImplementationsToInstance:(id<NSObject>) classInstance {
    [injector injectImplementationsToInstance:classInstance];
}

#pragma mark - Binding

+(void) setImplementation:(Class)clazz withProtocol:(Protocol*)protocol {
    [bindingService setImplementation:clazz withProtocol:protocol withBindingType:appleGuiceBindingTypeUserBinding];
}
+(void) setImplementations:(NSArray*)classes withProtocol:(Protocol*)protocol {
    [bindingService setImplementations:classes withProtocol:protocol withBindingType:appleGuiceBindingTypeUserBinding];
}

+(void) unsetImplementationOfProtocol:(Protocol*) protocol {
    [bindingService unsetImplementationOfProtocol:protocol];
}
+(void) unsetAllImplementations {
    [bindingService unsetAllImplementationsWithType:appleGuiceBindingTypeUserBinding];
}

#pragma mark - Settings

+(void) setIocPrefix:(NSString*) iocPrefix {
    settingsProvider.iocPrefix = iocPrefix;
}

+(void) setMethodInjectionPolicy:(AppleGuiceMethodInjectionPolicy)methodInjectionPolicy {
    [settingsProvider setMethodInjectionPolicy:methodInjectionPolicy];
    [AppleGuice _changeAutoInjectorStateIfNeeded];
}

+(void) setInstanceCreationPolicy:(AppleGuiceInstanceCreationPolicy)instanceCreationPolicy {
    [settingsProvider setInstanceCreateionPolicy:instanceCreationPolicy];
}

+(void) _changeAutoInjectorStateIfNeeded {
    switch (settingsProvider.methodInjectionPolicy) {
        case AppleGuiceMethodInjectionPolicyAutomatic:
            [AppleGuiceAutoInjector startAutoInjector];
            break;
        case AppleGuiceMethodInjectionPolicyManual:
        default:
            [AppleGuiceAutoInjector stopAutoInjector];
    }
}

@end