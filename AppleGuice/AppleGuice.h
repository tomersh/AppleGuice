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

#import "AppleGuiceSettingsProviderProtocol.h"
#import "AppleGuiceMacros.h"
#import "AppleGuiceInjectable.h"
#import "AppleGuiceSingleton.h"
#import "NSObject+AppleGuice.h"
#import "AppleGuiceOptional.h"

typedef enum AppleGuiceImplementationDiscoveryPolicy {
    AppleGuiceImplementationDiscoveryPolicyNoAutoDiscovery = 0,
    AppleGuiceImplementationDiscoveryPolicyPreCompile = 1,
    AppleGuiceImplementationDiscoveryPolicyRuntime = 2
} AppleGuiceImplementationDiscoveryPolicy;

@interface AppleGuice : NSObject


///-----------------------------
/// @name Initialize AppleGuice
///-----------------------------

/**
 Starts the service with the default implementation discovery policy: AppleGuiceImplementationDiscoveryPolicyPreCompile
*/
+(void) startService;

/**
 Starts the service with custom implementation discovery policy.
 @param implementationDiscoveryPolicy custom implementation discovery policy.
    - AppleGuiceImplementationDiscoveryPolicyNoAutoDiscovery No implementation auto discovery. In this mode you must bind your implementations manually.
    - AppleGuiceImplementationDiscoveryPolicyPreCompile A pre-compile script will resolve all the necessary bindings and will store them in `AppleGuiceBindingBootstrapper`. This is the default implementation discovery policy.
    - AppleGuiceImplementationDiscoveryPolicyRuntime Implementation auto discovery using objc/runtime introspection.
 
    @see setImplementation:withProtocol:
    @see setImplementations:withProtocol:
*/
+(void) startServiceWithImplementationDiscoveryPolicy:(AppleGuiceImplementationDiscoveryPolicy) implementationDiscoveryPolicy;

/**
 Stops the service. AutoInjector will stop and all binding will be removed.
 */
+(void) stopService;

///-----------------------------
/// @name Inject Implementations
///-----------------------------

/**
 Returns an instance of the class clazz. All of the ivar's with the IOC prefix will be initialized and will be available for the init function.
 instanceForClass: is equivalent of [[clazz alloc] init] when AppleGuiceMethodInjectionPolicy is set to AppleGuiceMethodInjectionPolicyAutomatic.
 @param clazz Class type
 @return an instance of the class clazz
*/
+(id<NSObject>) instanceForClass:(Class) clazz;

/**
 Returns an instance of the first implementation of protocol. All of the ivar's with the IOC prefix will be initialized and will be available for the init function.
 @param protocol protocol type
 @return an instance of Protocol protocol
 */
+(id<NSObject>) instanceForProtocol:(Protocol*) protocol;

/**
 Returns an array containing instances of all implementations of protocol. All of the ivar's with the IOC prefix will be initialized and will be available for the init function.
 @param protocol protocol type
 @return an array containing instances of Protocol protocol
 */
+(NSArray*) allInstancesForProtocol:(Protocol*) protocol;


/**
 Returns an array containing classes of all implementations of protocol.
 @param protocol protocol type
 @return an array containing classes type of Protocol protocol, an empty array will be returned if @param protocol is nil.
*/
+(NSArray*) allClassesForProtocol:(Protocol*) protocol;

/**
 Initialize all ivar's with the IOC prefix.
 @param classInstance an instance of a class
 */
+(void) injectImplementationsToInstance:(id<NSObject>) classInstance;


///-----------------------------
/// @name Manual bindings
///-----------------------------

/**
 Add binding between a class and a protocol. Adding a binding to a protocol will override *any* implementation discovery policy.
 @param clazz class to bind
 @param protocol protocol to bind to
 */
+(void) setImplementation:(Class) clazz withProtocol:(Protocol*) protocol;

/**
 Add binding between a list of classes and a protocol. Adding a binding to a protocol will override *any* implementation discovery policy.
 @param classes a list of classes implementing protocol
 @param protocol protocol to bind to
 */
+(void) setImplementations:(NSArray*) classes withProtocol:(Protocol*) protocol;

/**
 Unset all implementations of protocol that were set with setImplementation:withProtocol: or setImplementations:withProtocol:
 @param protocol protocol
 */
+(void) unsetImplementationOfProtocol:(Protocol*) protocol;

/**
 Unset all implementations that were set with setImplementation:withProtocol: or setImplementations:withProtocol:
 */
+(void) unsetAllImplementations;

///-----------------------------
/// @name Settings
///-----------------------------

/**
 Set the IOC prefix.
 Default is _ioc_
 @param iocPrefix new IOC prefix
*/
+(void) setIocPrefix:(NSString*) iocPrefix;

/**
 Sets the pre compile bootstrapper class name.
 Default is AppleGuiceBootsrapper which is autogenerated by AppleGuice.
 @param bootstrapperClass a class that conforms to AppleGuiceBootsrapperProtocol
*/
+(void) setBootstrapperClassName:(NSString*) bootstrapperClassName;

/**
 Set method injection policy.
    - AppleGuiceMethodInjectionPolicyAutomatic Inject implementations to all ivar containing the IOC prefix when calling init.
    - AppleGuiceMethodInjectionPolicyManual Inject implementations to all ivar containing the IOC prefix when calling one of the injection methods.
 default is AppleGuiceMethodInjectionPolicyAutomatic
 @param methodInjectionPolicy AppleGuiceMethodInjectionPolicy
 */
+(void) setMethodInjectionPolicy:(AppleGuiceMethodInjectionPolicy) methodInjectionPolicy;

/**
 Set instance creation policy.
    - AppleGuiceInstanceCreationPolicyDefault No instance manipulation
    - AppleGuiceInstanceCreationPolicySingletons Will always return the same instance of the object
    - AppleGuiceInstanceCreationPolicyLazyLoad Upon injection, a proxy object will be returned. The ivar will be initialized just before its first use.
    - AppleGuiceInstanceCreationPolicyCreateMocks if OCMock is available, a mock will be injected instead of a real object. Use this option for unit tests only.
 default is AppleGuiceInstanceCreationPolicyDefault. Policies can be combined with |
 @param instanceCreationPolicy AppleGuiceInstanceCreationPolicy
 */
+(void) setInstanceCreationPolicy:(AppleGuiceInstanceCreationPolicy) instanceCreationPolicy;

/**
 Set implementation availability policy.
 - AppleGuiceImplementationAvailabilityPolicyRequired throws an AppleGuiceInjectableImplementationNotFoundException if there is no injectable implemntation present for a given ivar during object init.
 - AppleGuiceImplementationAvailabilityPolicyOptional set an injectable ivar to nil if there is no injectable implemntation present during object init.

 @param instanceCreationPolicy AppleGuiceImplementationAvailabilityPolicy
 */
+(void) setImplementationAvailabilityPolicy:(AppleGuiceImplementationAvailabilityPolicy) implementationAvailabilityPolicy;

@end
