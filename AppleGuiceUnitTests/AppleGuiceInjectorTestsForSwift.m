//
//  AppleGuiceInjectorTestsForSwift.m
//  AppleGuiceUnitTests
//
//  Created by Alex on 30/03/2018.
//  Copyright © 2018 Tomer Shiri. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestBase.h"
#import "AppleGuiceInjector.h"
#import "AppleguiceSettingsProvider.h"
#import "AppleGuiceInstanceCreatorProtocol.h"
#import "AppleGuiceInjectableImplementationNotFoundException.h"
#import "AppleGuiceMockProviderProtocol.h"
#import "AppleGuiceOptional.h"
#import "AppleGuiceUnitTests-Swift.h"

@interface AppleGuiceInjectorTestsForSwift : TestBase

@end

@implementation AppleGuiceInjectorTestsForSwift {
    AppleGuiceInjector* serviceUnderTest;
    AppleGuiceSettingsProvider* settingsProvider;
    id instanceCreator;
}

-(void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceInjector alloc] init];
    
    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    instanceCreator = [[OCMockObject mockForProtocol:@protocol(AppleGuiceInstanceCreatorProtocol)] retain];
    
    serviceUnderTest.settingsProvider = settingsProvider;
    serviceUnderTest.instanceCreator = instanceCreator;
    
    settingsProvider.iocPrefix = testIocPrefix;
}

-(void)tearDown {
    [serviceUnderTest release];
    [settingsProvider release];
    [instanceCreator release];
    settingsProvider = nil;
    serviceUnderTest = nil;
    instanceCreator = nil;
    [super tearDown];
}

-(void) test__injectImplementationsToInstance__swiftClassWithNoIvars__doesNotThrow {
    id injectedClass = [[SwiftClassWithNoIvars alloc] init];
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:injectedClass]; }).toNot.raiseAny();
}

-(void) test__injectImplementationsToSwiftInstance__ivarWithoutIocPrefixAndWithDefaultInstanceCreationPolicy__ivarIsNotSet {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    SwiftClassWithNonInjectableIvars* instanceToInjectTo = [[SwiftClassWithNonInjectableIvars alloc] init];
    
    [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo];
    
    EXP_expect(instanceToInjectTo.nonInjectableIvar).to.equal(nil);
}

-(void) test__injectImplementationsToSwiftInstance__ivarWithoutIocPrefixAndWithLazyInstanceCreateionPolicy__ivarIsNotSet {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    SwiftClassWithNonInjectableIvars* instanceToInjectTo = [[SwiftClassWithNonInjectableIvars alloc] init];
    
    [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo];
    
    EXP_expect(instanceToInjectTo.nonInjectableIvar).to.equal(nil);
}

-(void) test__injectImplementationsSwiftToInstance__ivarWithoutIocPrefixAndWithSingletonInstanceCreationPolicy__ivarIsNotSet {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    SwiftClassWithNonInjectableIvars* instanceToInjectTo = [[SwiftClassWithNonInjectableIvars alloc] init];
    
    [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo];
    
    EXP_expect(instanceToInjectTo.nonInjectableIvar).to.equal(nil);
}

-(void) test__injectImplementationsToSwiftInstance__primitivesWithIocPrefixAndWithDefaultInstanceCreationPolicy__primitiveSetsToDefaultValues {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    SwiftClassWithPrimitiveInjectableIvars* instanceToInjectTo = [[SwiftClassWithPrimitiveInjectableIvars alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect(instanceToInjectTo._test_int).to.equal(0);
    EXP_expect(instanceToInjectTo._test_float).to.equal(0.0);
    EXP_expect(instanceToInjectTo._test_bool).to.equal(FALSE);
}

-(void) test__injectImplementationsToSwiftInstance__InstanceWithInjectableClassAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    SwiftClassWithInjectableClass* instanceToInjectTo = [[SwiftClassWithInjectableClass alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect([instanceToInjectTo._test_injectableObject isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToSwiftInstance__InstanceWithInjectableClassAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    Class injectedClass = [SwiftClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    SwiftClassWithInjectableClass* instanceToInjectTo = [[SwiftClassWithInjectableClass alloc] init];
    
    [[[instanceCreator expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    
    EXP_expect(instanceToInjectTo._test_injectableObject).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo._test_injectableObject isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableProtocolAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    SwiftClassWithInjectableProtocol* instanceToInjectTo = [[SwiftClassWithInjectableProtocol alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect([(id)instanceToInjectTo._test_injectableProtocol isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableProtocolAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    Class injectedClass = [SwiftClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    SwiftClassWithInjectableProtocol* instanceToInjectTo = [[SwiftClassWithInjectableProtocol alloc] init];
    
    [[[instanceCreator expect] andReturn:[[injectedClass alloc] init]] instanceForProtocol:@protocol(SwiftInjectedProtocol)];
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    EXP_expect(instanceToInjectTo._test_injectableProtocol).to.beKindOf([injectedClass class]);
    EXP_expect([(id)instanceToInjectTo._test_injectableProtocol isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableWithNoProtocolImplementation__throwsException {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    SwiftClassWithInjectableProtocol* instanceToInjectTo = [[SwiftClassWithInjectableProtocol alloc] init];
    
    [[[instanceCreator expect] andReturn:nil] instanceForProtocol:@protocol(SwiftInjectedProtocol)];
    
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).to.raise(NSStringFromClass([AppleGuiceInjectableImplementationNotFoundException class]));
    
    [instanceCreator verify];
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableWithNoProtocolImplementationAndOptionalImplementationAvailability__returnsNil {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.implementationAvailabilityPolicy = AppleGuiceImplementationAvailabilityPolicyOptional;
    SwiftClassWithInjectableProtocol* instanceToInjectTo = [[SwiftClassWithInjectableProtocol alloc] init];
    
    [[[instanceCreator expect] andReturn:nil] instanceForProtocol:@protocol(SwiftInjectedProtocol)];
    
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    
    EXP_expect(instanceToInjectTo._test_injectableProtocol).to.beNil;
    [instanceCreator verify];
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableWithNoProtocolImplementationWithAppleGuiceOptionalProtocol__returnsNil {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.implementationAvailabilityPolicy = AppleGuiceImplementationAvailabilityPolicyRequired;
    SwiftClassWithInjectableOptionalProtocol* instanceToInjectTo = [[SwiftClassWithInjectableOptionalProtocol alloc] init];
    
    [[[instanceCreator expect] andReturn:nil] instanceForProtocol:@protocol(SwiftOptionalProtocolWithNoImplementation)];
    
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    
    EXP_expect(instanceToInjectTo._test_optionalObject).to.beNil;
    [instanceCreator verify];
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableArrayAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    SwiftClassWithInjectableArray* instanceToInjectTo = [[SwiftClassWithInjectableArray alloc] init];
    
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect([instanceToInjectTo._test_InjectedProtocol isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToSwiftInstance__InstanceInjectableArrayAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    SwiftClassWithInjectableArray* instanceToInjectTo = [[SwiftClassWithInjectableArray alloc] init];
    
    //InjectedProtocol is an ObjC protocol. Automatic aarray injection won't work for swift protocols.
    [[[instanceCreator expect] andReturn:[NSArray array]] allInstancesForProtocol:@protocol(InjectedProtocol)];
    [[[instanceCreator expect] andReturn:[NSArray array]] allInstancesForProtocol:nil];
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    EXP_expect(instanceToInjectTo._test_InjectedProtocol).to.beKindOf([NSArray class]);
    EXP_expect([instanceToInjectTo._test_InjectedProtocol isProxy]).to.beFalsy();
}

-(void) test_injectImplementationsToSwiftInstance_instanceCreatorReturnsNil_throwsError {
    
    SwiftClassWithInjectableClass* instanceToInjectTo = [[SwiftClassWithInjectableClass alloc] init];
    
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    [[[instanceCreator expect] andReturn:nil] instanceForClass:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).to.raise(@"AppleGuiceInjectableImplementationNotFoundException");
    [instanceCreator verify];
}

@end
