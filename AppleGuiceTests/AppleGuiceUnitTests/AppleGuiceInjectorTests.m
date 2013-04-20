//
//  AppleGuiceInjectorTests.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 3/28/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceInjectorTests.h"
#import "AppleGuiceInjector.h"
#import "AppleguiceSettingsProvider.h"
#import "AppleGuiceInstanceCreatorProtocol.h"
#import "AppleGuiceInjectableImplementationNotFoundException.h"
#import "AppleGuiceMockProviderProtocol.h"

@protocol InjectedProtocol <NSObject>
@end


@interface ClassWithNoIvars : NSObject {
}
@end
@implementation ClassWithNoIvars
@end


@interface ClassWithNonInjectableIvars : NSObject {
@public
    NSObject* nonInjectableIvar;
}
@end
@implementation ClassWithNonInjectableIvars
@end


@interface ClassWithPrimitiveInjectableIvars : NSObject {
@public
    iocPrimitive(int, int);
    iocPrimitive(float, float);
    iocPrimitive(BOOL, bool);
}
@end
@implementation ClassWithPrimitiveInjectableIvars
@end


@interface SuperClassWithInjectableClass : NSObject {
@public
    iocIvar(ClassWithNoIvars, injectableObjectInSuperclass);
}
@end
@implementation SuperClassWithInjectableClass
@end

@interface ClassWithInjectableClass : SuperClassWithInjectableClass {
@public
    iocIvar(ClassWithNoIvars, injectableObject);
}
@end
@implementation ClassWithInjectableClass
@end


@interface SuperClassWithInjectableProtocol : NSObject {
@public
    iocProtocol(InjectedProtocol, injectableProtocolInSuperclass);
}
@end
@implementation SuperClassWithInjectableProtocol
@end

@interface ClassWithInjectableProtocol : SuperClassWithInjectableProtocol {
@public
    iocProtocol(InjectedProtocol, injectableProtocol);
}
@end
@implementation ClassWithInjectableProtocol
@end


@interface SuperClassWithInjectableArray : NSObject {
@public
    iocIvar(NSArray, InjectedProtocolDoesNotExist);
}
@end
@implementation SuperClassWithInjectableArray
@end

@interface ClassWithInjectableArray : SuperClassWithInjectableArray {
@public
    iocIvar(NSArray, InjectedProtocol);
}
@end
@implementation ClassWithInjectableArray
@end

@implementation AppleGuiceInjectorTests {
    AppleGuiceInjector* serviceUnderTest;
    AppleGuiceSettingsProvider* settingsProvider;
    id instanceCreator;
    id mockProvider;
}

-(void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceInjector alloc] init];
    
    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    instanceCreator = [OCMockObject mockForProtocol:@protocol(AppleGuiceInstanceCreatorProtocol)];
    mockProvider = [OCMockObject mockForProtocol:@protocol(AppleGuiceMockProviderProtocol)];
    serviceUnderTest.settingsProvider = settingsProvider;
    serviceUnderTest.instanceCreator = instanceCreator;
    serviceUnderTest.mockProvoider = mockProvider;
    
    settingsProvider.iocPrefix = testIocPrefix;
}

-(void) test__injectImplementationsToInstance__classInstanceIsNil__doesNotThrow {
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:nil]; }).toNot.raiseAny();
}

-(void) test__injectImplementationsToInstance__classWithNoIvars__doesNotThrow {
    id injectedClass = [[ClassWithNoIvars alloc] init];
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:injectedClass]; }).toNot.raiseAny();
}

-(void) test__injectImplementationsToInstance__ivarWithoutIocPrefixAndWithDefaultInstanceCreationPolicy__ivarIsNotSet {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithNonInjectableIvars* instanceToInjectTo = [[ClassWithNonInjectableIvars alloc] init];
    
    [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo];
    
    EXP_expect(instanceToInjectTo->nonInjectableIvar).to.equal(nil);
}

-(void) test__injectImplementationsToInstance__ivarWithoutIocPrefixAndWithLazyInstanceCreateionPolicy__ivarIsNotSet {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    ClassWithNonInjectableIvars* instanceToInjectTo = [[ClassWithNonInjectableIvars alloc] init];
    
    [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo];
    
    EXP_expect(instanceToInjectTo->nonInjectableIvar).to.equal(nil);
}

-(void) test__injectImplementationsToInstance__ivarWithoutIocPrefixAndWithSingletonInstanceCreationPolicy__ivarIsNotSet {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    ClassWithNonInjectableIvars* instanceToInjectTo = [[ClassWithNonInjectableIvars alloc] init];
    
    [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo];
    
    EXP_expect(instanceToInjectTo->nonInjectableIvar).to.equal(nil);
}

-(void) test__injectImplementationsToInstance__primitivesWithIocPrefixAndWithDefaultInstanceCreationPolicy__primitiveSetsToDefaultValues {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithPrimitiveInjectableIvars* instanceToInjectTo = [[ClassWithPrimitiveInjectableIvars alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect(instanceToInjectTo->test_int).to.equal(0);
    EXP_expect(instanceToInjectTo->test_float).to.equal(0.0);
    EXP_expect(instanceToInjectTo->test_bool).to.equal(FALSE);
}

-(void) test__injectImplementationsToInstance__InstanceWithInjectableClassAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    ClassWithInjectableClass* instanceToInjectTo = [[ClassWithInjectableClass alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect([instanceToInjectTo->test_injectableObject isProxy]).to.beTruthy();
    EXP_expect([instanceToInjectTo->test_injectableObjectInSuperclass isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToInstance__InstanceWithInjectableClassAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithInjectableClass* instanceToInjectTo = [[ClassWithInjectableClass alloc] init];
    
    [[[instanceCreator expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    [[[instanceCreator expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    [mockProvider verify];
    EXP_expect(instanceToInjectTo->test_injectableObject).to.beKindOf([injectedClass class]);
    EXP_expect(instanceToInjectTo->test_injectableObjectInSuperclass).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo->test_injectableObject isProxy]).to.beFalsy();
    EXP_expect([instanceToInjectTo->test_injectableObjectInSuperclass isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableProtocolAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    ClassWithInjectableProtocol* instanceToInjectTo = [[ClassWithInjectableProtocol alloc] init];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    [mockProvider verify];
    EXP_expect([instanceToInjectTo->test_injectableProtocol isProxy]).to.beTruthy();
    EXP_expect([instanceToInjectTo->test_injectableProtocolInSuperclass isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableProtocolAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithInjectableProtocol* instanceToInjectTo = [[ClassWithInjectableProtocol alloc] init];
    
    [[[instanceCreator expect] andReturn:[[injectedClass alloc] init]] instanceForProtocol:@protocol(InjectedProtocol)];
    [[[instanceCreator expect] andReturn:[[injectedClass alloc] init]] instanceForProtocol:@protocol(InjectedProtocol)];
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    [mockProvider verify];
    EXP_expect(instanceToInjectTo->test_injectableProtocol).to.beKindOf([injectedClass class]);
    EXP_expect(instanceToInjectTo->test_injectableProtocolInSuperclass).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo->test_injectableProtocol isProxy]).to.beFalsy();
    EXP_expect([instanceToInjectTo->test_injectableProtocolInSuperclass isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableWithNoProtocolImplementation__throwsException {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithInjectableProtocol* instanceToInjectTo = [[ClassWithInjectableProtocol alloc] init];
    
    [[[instanceCreator expect] andReturn:nil] instanceForProtocol:@protocol(InjectedProtocol)];
    
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).to.raise(NSStringFromClass([AppleGuiceInjectableImplementationNotFoundException class]));
    
    [instanceCreator verify];
    [mockProvider verify];
}


-(void) test__injectImplementationsToInstance__InstanceInjectableArrayAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    ClassWithInjectableArray* instanceToInjectTo = [[ClassWithInjectableArray alloc] init];
    
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    [mockProvider verify];
    EXP_expect([instanceToInjectTo->test_InjectedProtocol isProxy]).to.beTruthy();
    EXP_expect([instanceToInjectTo->test_InjectedProtocolDoesNotExist isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableArrayAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithInjectableArray* instanceToInjectTo = [[ClassWithInjectableArray alloc] init];
    
    [[[instanceCreator expect] andReturn:[NSArray array]] allInstancesForProtocol:@protocol(InjectedProtocol)];
    [[[instanceCreator expect] andReturn:[NSArray array]] allInstancesForProtocol:nil];
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    [mockProvider verify];
    EXP_expect(instanceToInjectTo->test_InjectedProtocol).to.beKindOf([NSArray class]);
    EXP_expect([instanceToInjectTo->test_InjectedProtocol isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceWithInjectableClassAndWithCreateMockInstanceCreationPolicy__mocksAreInjected {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    ClassWithInjectableClass* instanceToInjectTo = [[ClassWithInjectableClass alloc] init];
    
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    [[[mockProvider expect] andReturn:[[injectedClass alloc] init]] mockForClass:injectedClass];
    [[[mockProvider expect] andReturn:[[injectedClass alloc] init]] mockForClass:injectedClass];
    [[mockProvider reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    [mockProvider verify];
    EXP_expect(instanceToInjectTo->test_injectableObject).to.beKindOf([injectedClass class]);
    EXP_expect(instanceToInjectTo->test_injectableObjectInSuperclass).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo->test_injectableObject isProxy]).to.beFalsy();
    EXP_expect([instanceToInjectTo->test_injectableObjectInSuperclass isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceWithInjectableProtocolAndWithCreateMockInstanceCreationPolicy__mocksAreInjected {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    ClassWithInjectableProtocol* instanceToInjectTo = [[ClassWithInjectableProtocol alloc] init];
    
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[[mockProvider expect] andReturn:[[injectedClass alloc] init]]mockForProtocol:@protocol(InjectedProtocol)];
    [[[mockProvider expect] andReturn:[[injectedClass alloc] init]]mockForProtocol:@protocol(InjectedProtocol)];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    [mockProvider verify];
    EXP_expect(instanceToInjectTo->test_injectableProtocol).to.beKindOf([injectedClass class]);
    EXP_expect(instanceToInjectTo->test_injectableProtocolInSuperclass).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo->test_injectableProtocol isProxy]).to.beFalsy();
    EXP_expect([instanceToInjectTo->test_injectableProtocolInSuperclass isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableArrayAndWithCreateMockInstanceCreationPolicy__mocksAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    ClassWithInjectableArray* instanceToInjectTo = [[ClassWithInjectableArray alloc] init];
    
    [[instanceCreator reject] allInstancesForProtocol:OCMOCK_ANY];
    [[instanceCreator reject] instanceForClass:OCMOCK_ANY];
    [[instanceCreator reject] instanceForProtocol:OCMOCK_ANY];
    [[[mockProvider expect] andReturn:@"string"] mockForProtocol:@protocol(InjectedProtocol)];
    [[mockProvider reject] mockForClass:OCMOCK_ANY];
    [[[mockProvider expect] andReturn:@"string"] mockForProtocol:nil];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [instanceCreator verify];
    [mockProvider verify];
    EXP_expect(instanceToInjectTo->test_InjectedProtocol).to.beKindOf([NSArray class]);
    EXP_expect([instanceToInjectTo->test_InjectedProtocol isProxy]).to.beFalsy();
}

@end
