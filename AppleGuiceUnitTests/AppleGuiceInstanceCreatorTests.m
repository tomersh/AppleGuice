//
//  AppleGuiceInstanceCreatorTests.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/2/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceInstanceCreatorTests.h"
#import "AppleGuiceInstanceCreator.h"
#import "AppleGuiceSettingsProvider.h"
#import "AppleGuiceInjectorProtocol.h"
#import "AppleGuiceBindingServiceProtocol.h"
#import "AppleGuiceSingletonRepositoryProtocol.h"
#import "AppleguiceMockProviderProtocol.h"
#import "AppleGuiceSingleton.h"

@protocol AppleGuiceInstanceCreatorTestsTestProtocol<NSObject>
-(void) method;
@end

@interface TestClass : NSObject
@end
@implementation TestClass
@end


@implementation AppleGuiceInstanceCreatorTests {
    AppleGuiceInstanceCreator* serviceUnderTest;
    AppleGuiceSettingsProvider* settingsProvider;
    id singletonRepositoryMock;
    id bindingServiceMock;
    id injectorMock;
    id mockProviderMock;
}

-(void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceInstanceCreator alloc] init];
    
    settingsProvider = [[AppleGuiceSettingsProvider alloc] init];
    singletonRepositoryMock = [OCMockObject mockForProtocol:@protocol(AppleGuiceSingletonRepositoryProtocol)];
    bindingServiceMock = [OCMockObject mockForProtocol:@protocol(AppleGuiceBindingServiceProtocol)];
    injectorMock = [OCMockObject mockForProtocol:@protocol(AppleGuiceInjectorProtocol)];
    mockProviderMock = [OCMockObject mockForProtocol:@protocol(AppleGuiceMockProviderProtocol)];
    
    serviceUnderTest.settingsProvider = settingsProvider;
    serviceUnderTest.singletonRepository = singletonRepositoryMock;
    serviceUnderTest.bindingService = bindingServiceMock;
    serviceUnderTest.injector = injectorMock;
    serviceUnderTest.mockProvider = mockProviderMock;
}

-(void)tearDown {
    [serviceUnderTest release];
    [settingsProvider release];
    serviceUnderTest = nil;
    settingsProvider = nil;
    [super tearDown];
}

//instanceForClass

-(void) test__instanceForClass__nilClass__returnsNil {
    id classInstance = [serviceUnderTest instanceForClass:NSClassFromString(INVALID_CLASS_NAME)];
    EXP_expect(classInstance).to.equal(nil);
}

-(void) test__instanceForClass__validClassWithDefaultInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[injectorMock reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [bindingServiceMock verify];
    [injectorMock verify];
    XCTAssertEqual([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassWithDefaultInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[injectorMock expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [injectorMock verify];
    [bindingServiceMock verify];
    XCTAssertEqual([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassWithLazyLoadInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[injectorMock reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [bindingServiceMock verify];
    [injectorMock verify];
    XCTAssertEqual([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassWithLazyLoadInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyLazyLoad;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[injectorMock expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:[TestClass class]];
    
    [bindingServiceMock verify];
    [injectorMock verify];
    XCTAssertEqual([classInstance retainCount], (NSUInteger)1, @"object should be returned autoreleased");
    EXP_expect(classInstance).to.beInstanceOf([TestClass class]);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    Class mockedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    [[singletonRepositoryMock expect] setInstance:OCMArgOfKind(mockedClass) forClass:mockedClass];
    [[[singletonRepositoryMock expect] andReturn:nil] instanceForClass:mockedClass];
    
    id classInstance = [serviceUnderTest instanceForClass:mockedClass];
    
    [singletonRepositoryMock verify];
    EXP_expect(classInstance).to.beInstanceOf(mockedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    Class mockedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    [[singletonRepositoryMock expect] setInstance:OCMArgOfKind(mockedClass) forClass:mockedClass];
    [[[singletonRepositoryMock expect] andReturn:nil] instanceForClass:mockedClass];
    [[injectorMock expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:mockedClass];
    
    [injectorMock verify];
    [singletonRepositoryMock verify];
    EXP_expect(classInstance).to.beInstanceOf(mockedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonProtocolAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    Class injectedClass = [TestClass class];
    
    [[[bindingServiceMock expect] andReturn:@[ injectedClass ]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[singletonRepositoryMock expect] setInstance:OCMArgOfKind(injectedClass) forClass:injectedClass];
    [[[singletonRepositoryMock expect] andReturn:nil] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [singletonRepositoryMock verify];
    [bindingServiceMock verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenForTheFirstTimeWithSingletonProtocolAndManualInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    [[[bindingServiceMock expect] andReturn:@[ injectedClass ]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[singletonRepositoryMock expect] setInstance:OCMOCK_ANY forClass:injectedClass];
    [[[singletonRepositoryMock expect] andReturn:nil] instanceForClass:OCMOCK_ANY];
    [[injectorMock expect] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [injectorMock verify];
    [singletonRepositoryMock verify];
    [bindingServiceMock verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonInstanceCreationPolicyAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;

    [[singletonRepositoryMock reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepositoryMock expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [singletonRepositoryMock verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonInstanceCreationPolicyAndManualInjectionPolicy__NewInstanceIsReturned {
    Class injectedClass = [TestClass class];
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicySingletons;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;

    [[singletonRepositoryMock reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepositoryMock expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    [[injectorMock reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [injectorMock verify];
    [singletonRepositoryMock verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonProtocolAndAutomaticInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyAutomatic;
    
    Class injectedClass = [TestClass class];
    
    [[[bindingServiceMock expect] andReturn:@[ injectedClass ]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[singletonRepositoryMock reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepositoryMock expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [bindingServiceMock verify];
    [singletonRepositoryMock verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

-(void) test__instanceForClass__validClassSeenNotForTheFirstTimeWithSingletonProtocolAndManualInjectionPolicy__NewInstanceIsReturned {
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyDefault;
    settingsProvider.methodInjectionPolicy = AppleGuiceMethodInjectionPolicyManual;
    
    Class injectedClass = [TestClass class];
    [[[bindingServiceMock expect] andReturn:@[ injectedClass ]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[singletonRepositoryMock reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[[singletonRepositoryMock expect] andReturn:[[injectedClass alloc] init]] instanceForClass:OCMOCK_ANY];
    [[injectorMock reject] injectImplementationsToInstance:OCMOCK_ANY];
    
    id classInstance = [serviceUnderTest instanceForClass:injectedClass];
    
    [bindingServiceMock verify];
    [injectorMock verify];
    [singletonRepositoryMock verify];
    EXP_expect(classInstance).to.beInstanceOf(injectedClass);
}

//instanceForProtocol

-(void) test__instanceForProtocol__invalidProtocol__returnsNil {
    id result = [serviceUnderTest instanceForProtocol:NSProtocolFromString(INVALID_PROTOCOL_NAME)];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__noImplementations__returnsNil {
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(NSCopying)];
    id result = [serviceUnderTest instanceForProtocol:@protocol(NSCopying)];
    [bindingServiceMock verify];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__nilImplementations__returnsNil {
    [[[bindingServiceMock expect] andReturn:nil] getClassesForProtocol:@protocol(NSCopying)];
    id result = [serviceUnderTest instanceForProtocol:@protocol(NSCopying)];
    [bindingServiceMock verify];
    EXP_expect(result).to.beNil();
}

-(void) test__instanceForProtocol__singleImplementation__callsInstanceForClassWithFirstImplementation {
    Class injectedClass = [TestClass class];
    [[[bindingServiceMock expect] andReturn:@[ injectedClass, [NSArray class] ]] getClassesForProtocol:@protocol(NSCopying)];
    id partialMockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[partialMockedInjector expect] andReturn:[[injectedClass alloc] init]] instanceForClass:injectedClass];
    
    id result = [partialMockedInjector instanceForProtocol:@protocol(NSCopying)];
    
    [bindingServiceMock verify];
    [partialMockedInjector verify];
    EXP_expect(result).to.beKindOf(injectedClass);
}

//allInstancesForProtocol

-(void) test__allInstancesForProtocol__invalidProtocol__returnsNil {
    id result = [serviceUnderTest allInstancesForProtocol:NSProtocolFromString(INVALID_PROTOCOL_NAME)];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__noImplementations__returnsNil {
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(NSCopying)];
    id result = [serviceUnderTest allInstancesForProtocol:@protocol(NSCopying)];
    [bindingServiceMock verify];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__nilImplementations__returnsNil {
    [[[bindingServiceMock expect] andReturn:nil] getClassesForProtocol:@protocol(NSCopying)];
    id result = [serviceUnderTest allInstancesForProtocol:@protocol(NSCopying)];
    [bindingServiceMock verify];
    EXP_expect(result).to.beNil();
}

-(void) test__allInstancesForProtocol__validProtocols__InstanceForClassIsCalledForEachImplementation {
    Class injectedClass = [TestClass class];
    Protocol* protocol = @protocol(NSCopying);
    
    [[[bindingServiceMock expect] andReturn:@[ injectedClass, injectedClass ]] getClassesForProtocol:protocol];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:[NSSet set]] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[NSArray array]] instanceForClass:injectedClass];
    
    id result = [mockedInjector allInstancesForProtocol:protocol];
    
    [bindingServiceMock verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect(result).notTo.beKindOf([NSMutableArray class]);
    EXP_expect([result count]).to.equal(2);
    EXP_expect([result objectAtIndex:0]).to.beKindOf([NSSet class]);
    EXP_expect([result objectAtIndex:1]).to.beKindOf([NSArray class]);
}

-(void) test__allInstancesForProtocol__instanceForClassResturnsNil__instanceIsNotSaved {
    Class injectedClass = [TestClass class];
    Protocol* protocol = @protocol(NSCopying);
    
    [[[bindingServiceMock expect] andReturn:@[ injectedClass, injectedClass ]] getClassesForProtocol:protocol];
    id mockedInjector = [OCMockObject partialMockForObject:serviceUnderTest];
    [[[mockedInjector expect] andReturn:nil] instanceForClass:injectedClass];
    [[[mockedInjector expect] andReturn:[NSSet set]] instanceForClass:injectedClass];
    
    id result = [mockedInjector allInstancesForProtocol:protocol];
    
    [bindingServiceMock verify];
    [mockedInjector verify];
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect(result).notTo.beKindOf([NSMutableArray class]);
    EXP_expect([result count]).to.equal(1);
    EXP_expect([result objectAtIndex:0]).to.beKindOf([NSSet class]);
}


-(void) test_instanceForClass_classWithCreateMockInstanceCreationPolicy_mockIsReturned {
    __block TestClass* result;
    NSString* expectedResult = @"mock";
    Class clazz = [TestClass class];
    
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    [[[bindingServiceMock expect] andReturn:@[]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[[mockProviderMock expect] andReturn:expectedResult] mockForClass:clazz];
    [[mockProviderMock reject] mockForProtocol:OCMOCK_ANY];
    
    
    EXP_expect(^{
        result =[serviceUnderTest instanceForClass:clazz];
    }).toNot.raiseAny();
    
    
    [bindingServiceMock verify];
    [mockProviderMock verify];
    EXP_expect(result).to.equal(expectedResult);
}

-(void) test_instanceForClass_classWithCreateMockInstanceCreationPolicyAndSingletonAttributeinitializedForTheFirstTime_mockIsReturned {
    __block TestClass* result;
    NSString* expectedResult = @"mock";
    Class clazz = [TestClass class];
    
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    [[[bindingServiceMock expect] andReturn:@[ clazz ]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[[singletonRepositoryMock expect] andReturn:nil] instanceForClass:clazz];
    [[singletonRepositoryMock expect] setInstance:expectedResult forClass:clazz];
    [[[mockProviderMock expect] andReturn:expectedResult] mockForClass:clazz];
    [[mockProviderMock reject] mockForProtocol:OCMOCK_ANY];
    
    EXP_expect(^{
        result =[serviceUnderTest instanceForClass:clazz];
    }).toNot.raiseAny();
    
    
    [bindingServiceMock verify];
    [mockProviderMock verify];
    EXP_expect(result).to.equal(expectedResult);
}

-(void) test_instanceForClass_classWithCreateMockInstanceCreationPolicyAndSingletonAttributeinitializedNotForTheFirstTime_mockIsReturned {
    __block TestClass* result;
    NSString* expectedResult = @"mock";
    Class clazz = [TestClass class];
    
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    [[[bindingServiceMock expect] andReturn:@[ clazz ]] getClassesForProtocol:@protocol(AppleGuiceSingleton)];
    [[[singletonRepositoryMock expect] andReturn:expectedResult] instanceForClass:clazz];
    [[singletonRepositoryMock reject] setInstance:OCMOCK_ANY forClass:OCMOCK_ANY];
    [[mockProviderMock reject] mockForClass:OCMOCK_ANY];
    [[mockProviderMock reject] mockForProtocol:OCMOCK_ANY];
    
    
    EXP_expect(^{
        result =[serviceUnderTest instanceForClass:clazz];
    }).toNot.raiseAny();
    
    
    [bindingServiceMock verify];
    [mockProviderMock verify];
    EXP_expect(result).to.equal(expectedResult);
}

-(void) test_instanceForProtocol_validProtocolWithCreateMockInstanceCreationPolicy_oneMockIsCreated {
    __block id result1;
    NSString* expectedResult = @"mock";
    Protocol* protocol = @protocol(AppleGuiceInstanceCreatorTestsTestProtocol);
    
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    [[mockProviderMock reject] mockForClass:OCMOCK_ANY];
    [[[mockProviderMock expect] andReturn:expectedResult] mockForProtocol:protocol];
    
    
    EXP_expect(^{
        result1 =[serviceUnderTest instanceForProtocol:protocol];
    }).toNot.raiseAny();
    
    
    [mockProviderMock verify];
    EXP_expect(result1).to.equal(expectedResult);
}

-(void) test_allInstancesForProtocol_validProtocolWithCreateMockInstanceCreationPolicy_oneMockIsCreated {
    __block NSArray* result1;
    __block NSArray* result2;
    Protocol* protocol = @protocol(AppleGuiceInstanceCreatorTestsTestProtocol);
    
    settingsProvider.instanceCreateionPolicy = AppleGuiceInstanceCreationPolicyCreateMocks;
    [[mockProviderMock reject] mockForClass:OCMOCK_ANY];
    [[[mockProviderMock expect] andReturn:@"mock"] mockForProtocol:protocol];
    [[[mockProviderMock expect] andReturn:@"mock2"] mockForProtocol:protocol];

    
    EXP_expect(^{
        result1 =[serviceUnderTest allInstancesForProtocol:protocol];
        result2 =[serviceUnderTest allInstancesForProtocol:protocol];
    }).toNot.raiseAny();

    
    [mockProviderMock verify];
    EXP_expect(result1).to.beKindOf([NSArray class]);
    EXP_expect(result2).to.beKindOf([NSArray class]);
    EXP_expect([result1 count]).to.equal(1);
    EXP_expect([result1 count]).to.equal(1);
    EXP_expect(result1).notTo.equal(result2);
}

@end
