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
#import "AppleGuiceSettingsProvider.h"
#import "AppleGuiceSingletonRepository.h"
#import "AppleGuiceInstanceCreator.h"
#import "AppleGuiceSwiftProtocolDemangler.h"
#import "AppleGuiceBindingBootstrapperProtocol.h"
#import "AppleGuiceClassGenerator.h"

#import "AppleGuiceOCMockMockProvider.h"
#import "AppleGuiceOCMockitoMockProvider.h"
#import "AppleGuiceMockProviderSelectorService.h"

@implementation AppleGuice

static AppleGuiceBindingService* bindingService;
static AppleGuiceInjector* injector;
static AppleGuiceSingletonRepository* singletonRepository;
static AppleGuiceSettingsProvider* settingsProvider;
static AppleGuiceInstanceCreator* instanceCreator;
static AppleGuiceSwiftProtocolDemangler *swiftProtocolDemangler;

static BOOL didStart;

static id<AppleGuiceBindingBootstrapperProtocol> bootstrapper;

+(void)load {
    didStart = NO;
}

+(void) _initializeAppleGuice {

    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    bindingService = [[AppleGuiceBindingService alloc] init];
    injector = [[AppleGuiceInjector alloc] init];
    singletonRepository = [[AppleGuiceSingletonRepository alloc] init];
    instanceCreator = [[AppleGuiceInstanceCreator alloc] init];
    swiftProtocolDemangler = [[AppleGuiceSwiftProtocolDemangler alloc] init];
    
    bindingService.classGenerator = [[[AppleGuiceClassGenerator alloc] init] autorelease];
    
    
    instanceCreator.bindingService = bindingService;
    instanceCreator.settingsProvider = settingsProvider;
    instanceCreator.injector = injector;
    instanceCreator.singletonRepository = singletonRepository;
    instanceCreator.mockProvider = [[self class] _selectMockProvider];
    
    injector.settingsProvider = settingsProvider;
    injector.instanceCreator = instanceCreator;
    injector.swiftProtocolDemangler = swiftProtocolDemangler;
    
    Class bootstrapperClass = NSClassFromString(settingsProvider.bootstrapperClassName);
    bootstrapper = [[bootstrapperClass alloc] init];
    bootstrapper.bindingService = bindingService;
}

+(id<AppleGuiceMockProviderProtocol>) _selectMockProvider {
    NSArray* mockProviders = @[
                               [[[AppleGuiceOCMockMockProvider alloc] init] autorelease],
                               [[[AppleGuiceOCMockitoMockProvider alloc] init] autorelease]
                              ];
    
    id<AppleGuiceMockProviderSelectorServiceProtocol> mockSelector = [[[AppleGuiceMockProviderSelectorService alloc] init] autorelease];
    
    [mockSelector setMockProviders:mockProviders];
    
    return [mockSelector getSelectedMockProvider];
}

#pragma mark - Bootstrap

+(void) startService {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyPreCompile];
}

+(void) startServiceWithImplementationDiscoveryPolicy:(AppleGuiceImplementationDiscoveryPolicy) implementationDiscoveryPolicy {
    if (didStart) {
        return;
    }
    didStart = YES;
    
    [self _initializeAppleGuice];
    
    switch (implementationDiscoveryPolicy) {
        case AppleGuiceImplementationDiscoveryPolicyPreCompile:
            [bootstrapper bootstrap];
            break;
        case AppleGuiceImplementationDiscoveryPolicyNoAutoDiscovery:
        default:
            break;
    }
    [AppleGuiceAutoInjector setInjector:injector];
    [AppleGuice _changeAutoInjectorStateIfNeeded];
}

+(void) stopService {
    [AppleGuiceAutoInjector stopAutoInjector];
    [bindingService unsetAllImplementationsWithType:appleGuiceBindingTypeCachedBinding];
    [bindingService unsetAllImplementationsWithType:appleGuiceBindingTypeUserBinding];
    [singletonRepository clearRepository];
    didStart = NO;
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

+(NSArray*) allClassesForProtocol:(Protocol*) protocol {
    if (!protocol) return @[];
    return [bindingService getClassesForProtocol:protocol];
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

+(void) setBootstrapperClassName:(NSString*) bootstrapperClassName {
    settingsProvider.bootstrapperClassName = bootstrapperClassName;
}

+(void) setMethodInjectionPolicy:(AppleGuiceMethodInjectionPolicy)methodInjectionPolicy {
    settingsProvider.methodInjectionPolicy = methodInjectionPolicy;
    
    [AppleGuice _changeAutoInjectorStateIfNeeded];
}

+(void) setInstanceCreationPolicy:(AppleGuiceInstanceCreationPolicy)instanceCreationPolicy {
    settingsProvider.instanceCreateionPolicy = instanceCreationPolicy;
}

+(void) setImplementationAvailabilityPolicy:(AppleGuiceImplementationAvailabilityPolicy) implementationAvailabilityPolicy {
    settingsProvider.implementationAvailabilityPolicy = implementationAvailabilityPolicy;
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
