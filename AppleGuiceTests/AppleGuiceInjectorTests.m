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
#import "AppleguiceSingletonRepository.h"
#import "AppleGuiceSingleton.h"
#import "AppleGuiceProtocolLocator.h"

#define testIocPrefix @"test_"
#define iocIvar(__clazz, __name) __clazz* test_##__name
#define iocPrimitive(__type, __name) __type test_##__name
#define iocProtocol(__type, __name) id<__type> test_##__name

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
    id singletonRepository;
    id protocolLocator;
}

-(void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceInjector alloc] init];
    
    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    singletonRepository = [OCMockObject mockForProtocol:@protocol(AppleGuiceSingletonRepositoryProtocol)];
    protocolLocator = [OCMockObject mockForProtocol:@protocol(AppleGuiceProtocolLocatorProtocol)];
    
    serviceUnderTest.settingsProvider = settingsProvider;
    serviceUnderTest.singletonRepository = singletonRepository;
    serviceUnderTest.protocolLocator = protocolLocator;
    
    settingsProvider.iocPrefix = testIocPrefix;
}

-(void) test__instanceForClass__nilClass__returnsNil {
    id classInstance = [serviceUnderTest instanceForClass:NSClassFromString(INVALID_CLASS_NAME)];
    EXP_expect(classInstance).to.equal(nil);
}

//instanceForClass

-(void) test__instanceForClass__validClassWithDefaultInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[mockedInjector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:[ClassWithNoIvars class]];
    
    [protocolLocator verify];
    [mockedInjector verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([ClassWithNoIvars class]);
}

-(void) test__instanceForClass__validClassWithDefaultInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andForwardToRealObject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:[ClassWithNoIvars class]];
    
    [mockedInjector verify];
    [protocolLocator verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([ClassWithNoIvars class]);
}

-(void) test__instanceForClass__validClassWithLazyLoadInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[mockedInjector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:[ClassWithNoIvars class]];
    
    [protocolLocator verify];
    [mockedInjector verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([ClassWithNoIvars class]);
}

-(void) test__instanceForClass__validClassWithLazyLoadInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andForwardToRealObject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:[ClassWithNoIvars class]];
    
    [protocolLocator verify];
    [mockedInjector verify];
    STAssertEquals([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([ClassWithNoIvars class]);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(no)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[singletonRepository reject]  instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[ClassWithNoIvars class]];
    
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf([ClassWithNoIvars class]);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(no)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:[ClassWithNoIvars class]];
    [[singletonRepository reject]  instanceForClass:OCMOCK_ANY];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andForwardToRealObject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:[ClassWithNoIvars class]];
    
    [mockedInjector verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf([ClassWithNoIvars class]);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonProtocolAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    Class injectedClass = [ClassWithNoIvars class];
    
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(no)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:injectedClass];
    [[singletonRepository reject]  instanceForClass:OCMOCK_ANY];

    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonProtocolAndManualInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(no)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository expect] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[singletonRepository reject]  instanceForClass:OCMOCK_ANY];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andForwardToRealObject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:injectedClass];
    
    [mockedInjector verify];
    [singletonRepository verify];
    [protocolLocator verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(yes)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
        
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(yes)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[mockedInjector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:injectedClass];
    
    [mockedInjector verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonProtocolAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    Class injectedClass = [ClassWithNoIvars class];
    
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(yes)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [protocolLocator verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonProtocolAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    Class injectedClass = [ClassWithNoIvars class];
    [[[protocolLocator expect] andReturn:@[ injectedClass ]] getAllClassesByProtocolType:@protocol(AppleGuiceSingleton)];
    [[[singletonRepository expect] andReturnValue:OCMOCK_VALUE(yes)] hasInstanceForClass:OCMOCK_ANY];
    [[singletonRepository reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepository expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[mockedInjector reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [mockedInjector instanceForClass:injectedClass];
    
    [protocolLocator verify];
    [mockedInjector verify];
    [singletonRepository verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

//instanceForProtocol

-(void) test__instanceForProtocol__invalidProtocol__returnsNil {
    id result = [serviceUnderTest instanceForProtocol:NSProtocolFromString(INVALID_PROTOCOL_NAME)];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__noImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest instanceForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__nilImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:nil] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest instanceForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__singleImplementation__callsInstanceForClassWithFirstImplementation {
    Class injectedClass = [ClassWithNoIvars class];
    [[[protocolLocator expect] andReturn:@[ injectedClass, [NSArray class] ]] getAllClassesByProtocolType:@protocol(NSCopying)];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    
    id result = [mockedInjector instanceForProtocol:@protocol(NSCopying)];
    
    [protocolLocator verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf(injectedClass);
}

//allInstancesForProtocol

-(void) test__allInstancesForProtocol__invalidProtocol__returnsNil {
    id result = [serviceUnderTest allInstancesForProtocol:NSProtocolFromString(INVALID_PROTOCOL_NAME)];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__noImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:@[]] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest allInstancesForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__nilImplementations__returnsNil {
    [[[protocolLocator expect] andReturn:nil] getAllClassesByProtocolType:@protocol(NSCopying)];
    id result = [serviceUnderTest allInstancesForProtocol:@protocol(NSCopying)];
    [protocolLocator verify];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__validProtocols__InstanceForClassIsCalledForEachImplementation {
    Class injectedClass = [ClassWithNoIvars class];
    Protocol* protocol = @protocol(NSCopying);
    
    [[[protocolLocator expect] andReturn:@[ injectedClass, injectedClass ]] getAllClassesByProtocolType:protocol];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[[NSSet alloc] init]] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[[NSArray alloc] init]] instanceForClass:injectedClass];
    
    id result = [mockedInjector allInstancesForProtocol:protocol];
    
    [protocolLocator verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect(result).notTo.beKindOf([NSMutableArray class]);
    EXP_expect([result count]).to.equal(2);
    EXP_expect([result objectAtIndex:0]).to.beKindOf([NSSet class]);
    EXP_expect([result objectAtIndex:1]).to.beKindOf([NSArray class]);
}

-(void) test__allInstancesForProtocol__instanceForClassResturnsNil__instanceIsNotSaved {
    Class injectedClass = [ClassWithNoIvars class];
    Protocol* protocol = @protocol(NSCopying);
    
    [[[protocolLocator expect] andReturn:@[ injectedClass, injectedClass ]] getAllClassesByProtocolType:protocol];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:nil] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[[NSSet alloc] init]] instanceForClass:injectedClass];
    
    id result = [mockedInjector allInstancesForProtocol:protocol];
    
    [protocolLocator verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect(result).notTo.beKindOf([NSMutableArray class]);
    EXP_expect([result count]).to.equal(1);
    EXP_expect([result objectAtIndex:0]).to.beKindOf([NSSet class]);
}

//injectImplementationsToInstance

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
    
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    [[mockedInjector reject] allInstancesForProtocol:OCMOCK_ANY];
    [[mockedInjector reject] instanceForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [mockedInjector injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [mockedInjector verify];
    EXP_expect(instanceToInjectTo->test_injectableObject).to.beKindOf([injectedClass class]);
    EXP_expect(instanceToInjectTo->test_injectableObjectInSuperclass).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo->test_injectableObject isProxy]).to.beFalsy();
    EXP_expect([instanceToInjectTo->test_injectableObjectInSuperclass isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableProtocolAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    ClassWithInjectableProtocol* instanceToInjectTo = [[ClassWithInjectableProtocol alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect([instanceToInjectTo->test_injectableProtocol isProxy]).to.beTruthy();
    EXP_expect([instanceToInjectTo->test_injectableProtocolInSuperclass isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableProtocolAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    Class injectedClass = [ClassWithNoIvars class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithInjectableProtocol* instanceToInjectTo = [[ClassWithInjectableProtocol alloc] init];
    
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForProtocol:@protocol(InjectedProtocol)];
    [[[mockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForProtocol:@protocol(InjectedProtocol)];
    [[mockedInjector reject] instanceForClass:OCMOCK_ANY];
    [[mockedInjector reject] allInstancesForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [mockedInjector injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [mockedInjector verify];
    EXP_expect(instanceToInjectTo->test_injectableProtocol).to.beKindOf([injectedClass class]);
    EXP_expect(instanceToInjectTo->test_injectableProtocolInSuperclass).to.beKindOf([injectedClass class]);
    EXP_expect([instanceToInjectTo->test_injectableProtocol isProxy]).to.beFalsy();
    EXP_expect([instanceToInjectTo->test_injectableProtocolInSuperclass isProxy]).to.beFalsy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableArrayAndWithLazyLoadInstanceCreationPolicy__proxiesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    ClassWithInjectableArray* instanceToInjectTo = [[ClassWithInjectableArray alloc] init];
    
    EXP_expect(^{ [serviceUnderTest injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    
    EXP_expect([instanceToInjectTo->test_InjectedProtocol isProxy]).to.beTruthy();
    EXP_expect([instanceToInjectTo->test_InjectedProtocolDoesNotExist isProxy]).to.beTruthy();
}

-(void) test__injectImplementationsToInstance__InstanceInjectableArrayAndWithDefaultInstanceCreationPolicy__instancesAreInjected {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    ClassWithInjectableArray* instanceToInjectTo = [[ClassWithInjectableArray alloc] init];
    
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[[NSArray alloc] init]] allInstancesForProtocol:@protocol(InjectedProtocol)];
    [[[mockedInjector expect] andReturn:[[NSArray alloc] init]] allInstancesForProtocol:nil];
    [[mockedInjector reject] instanceForClass:OCMOCK_ANY];
    [[mockedInjector reject] instanceForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{ [mockedInjector injectImplementationsToInstance:instanceToInjectTo]; }).toNot.raiseAny();
    [mockedInjector verify];
    EXP_expect(instanceToInjectTo->test_InjectedProtocol).to.beKindOf([NSArray class]);
    EXP_expect([instanceToInjectTo->test_InjectedProtocol isProxy]).to.beFalsy();
}

@end
