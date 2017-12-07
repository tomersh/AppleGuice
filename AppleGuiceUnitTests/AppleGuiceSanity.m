//
//  AppleGuiceSanity.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/10/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceSanity.h"
#import "APPleGuice.h"
#import "AppleGuiceInjectableImplementationNotFoundException.h"
#import "AppleGuiceInvocationProxy.h"

#define Implementation(__clazzName) @implementation __clazzName @end

@implementation AppleGuiceSanity

-(void)setUp {
    [super setUp];
    [AppleGuice stopService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyDefault];
    [AppleGuice startService];
    [AppleGuice setIocPrefix:testIocPrefix];
}

-(void)tearDown {
    [super tearDown];
    [AppleGuice stopService];
}

#pragma mark - pre compile discovery policy

-(void) test__instanceForClass__ComplexObjectInitializedWithDefaultPolicies__AllFieldsAreInjected {
    __block AppleGuiceSanityTestClass* result;
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];

}

-(void) test__instanceForClass__ComplexObjectInitializedWithSingletonCreationPolicy__allIvarsAreInjectedWithSingletons {
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicySingletons];
    __block AppleGuiceSanityTestClass* result;
    __block AppleGuiceSanityTestClass* secondResult;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    EXP_expect(^{ secondResult = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateTestClassIntegrity:secondResult];
    [self validateInjectedIvarInInstance:result areEqualToInjectedIvarsInInstance:secondResult];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadCreationPolicy__allIvarsAreInjectedWithProxies {
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad];
    __block AppleGuiceSanityTestClass* result;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateInjectedIvarsAreProxies:result];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadAndSingletonsCreationPolicy__allIvarsAreInjectedWithProxies {
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad | AppleGuiceInstanceCreationPolicySingletons];
    __block AppleGuiceSanityTestClass* result;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateInjectedIvarsAreProxies:result];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadAndSingletonsCreationPolicy__proxiesAreConvertedToSingletons {
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad | AppleGuiceInstanceCreationPolicySingletons];
    AppleGuiceSanityTestClass* result = [[AppleGuiceSanityTestClass alloc] init];
    AppleGuiceSanityTestClass* secondResult = [[AppleGuiceSanityTestClass alloc] init];
    
    id generatedObject1 = ((AppleGuiceInvocationProxy*)result.test_standAloneClass).createInstanceBlock();
    id generatedObject2 = ((AppleGuiceInvocationProxy*)secondResult.test_standAloneClass).createInstanceBlock();
    
    EXP_expect(generatedObject1).to.equal(generatedObject2);
}

#pragma mark - all ways to instantiate

//regular

-(void) test_instanceForClass_InitClassWithInstanceForClass_returnsInstance {
    __block AppleGuiceSanityTestClass* result;
    EXP_expect(^{ result = (id)[AppleGuice instanceForClass:[AppleGuiceSanityTestClass class]]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
}

-(void) test_instanceForClass_InitClassWithInstanceForClassShorthand_returnsInstance {
    __block AppleGuiceSanityTestClass* result;
    EXP_expect(^{ result = (id)[AppleGuice instanceForClass:[AppleGuiceSanityTestClass class]]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
}

-(void) test_instanceForClass_InitClassWithProtocol_returnsInstance {
    Protocol* protocol = @protocol(TestInjectableProtocol);
    __block AppleGuiceSanityTestClass* result;
    EXP_expect(^{ result = (id)[AppleGuice instanceForProtocol:protocol]; }).notTo.raiseAny();
    
    EXP_expect(result).notTo.beNil;
    EXP_expect(result).to.conformTo(protocol);
}

-(void) test_instanceForClass_InitClassWithProtocols_returnsInstances {
    Protocol* protocol = @protocol(TestInjectableProtocol);
    __block NSArray* result;
    EXP_expect(^{ result = [AppleGuice allInstancesForProtocol:protocol]; }).notTo.raiseAny();
    
    EXP_expect(result).notTo.beNil;
    EXP_expect([result count]).to.equal(2);

    NSArray* implementations = @[[TestInjectableProtocolImplementor class], [AnotherTestInjectableProtocolImplementor class]];
    
    EXP_expect(implementations).to.contain([result[0] class]);
    EXP_expect(implementations).to.contain([result[1] class]);
}

//singleton

-(void) test_instanceForClass_InitSingletonClassWithInstanceForClass_returnsInstance {
    __block TestInjectableSingletonClass* result1, *result2;
    EXP_expect(^{ result1 = (id)[AppleGuice instanceForClass:[TestInjectableSingletonClass class]]; result2 = (id)[AppleGuice instanceForClass:[TestInjectableSingletonClass class]]; }).notTo.raiseAny();
    
    EXP_expect(result1).to.equal(result2);
}

-(void) test_instanceForClass_InitSingletonClassWithInstanceForClassShorthand_returnsInstance {
    __block TestInjectableSingletonClass* result1, *result2;
    EXP_expect(^{ result1 = (id)[AppleGuice instanceForClass:[TestInjectableSingletonClass class]];
        result2 = (id)[AppleGuice instanceForClass:[TestInjectableSingletonClass class]]; }).notTo.raiseAny();
    
    EXP_expect(result1).to.equal(result2);
}

-(void) test_instanceForClass_InitSingletonClassWithProtocol_returnsInstance {
    Protocol* protocol = @protocol(TestProtocolForSingletonClasses);
    __block TestInjectableSingletonClass* result1, *result2;
    EXP_expect(^{ result1 = (id)[AppleGuice instanceForProtocol:protocol];
        result2 = (id)[AppleGuice instanceForProtocol:protocol]; }).notTo.raiseAny();
    
    EXP_expect(result1).to.equal(result2);
}

-(void) test_instanceForClass_InitSingletonClassWithProtocols_returnsInstances {
    Protocol* protocol = @protocol(TestProtocolForSingletonClasses);
    __block TestInjectableSingletonClass* result1;
    __block NSArray* result2;
    EXP_expect(^{ result1 = (id)[AppleGuice instanceForProtocol:protocol];
        result2 = [AppleGuice allInstancesForProtocol:protocol]; }).notTo.raiseAny();
    
    EXP_expect([result2 count]).to.equal(1);
    EXP_expect(result1).to.equal(result2[0]);
}

//create mocks

//regular

-(void) test_instanceForClass_InitClassWithInstanceForClassAndMockCreationPolicy_returnsInstance {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    __block id result;
    EXP_expect(^{ result = [AppleGuice instanceForClass:[AppleGuiceSanityTestClass class]]; }).notTo.raiseAny();
    
    [result verify];
}

-(void) test_instanceForClass_InitClassWithInstanceForClassShorthandAndMockCreationPolicy_returnsInstance {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    __block id result;
    EXP_expect(^{ result = [AppleGuice instanceForClass:[AppleGuiceSanityTestClass class]]; }).notTo.raiseAny();
    
    [result verify];
}

-(void) test_instanceForClass_InitClassWithProtocolAndMockCreationPolicy_returnsInstance {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    Protocol* protocol = @protocol(TestInjectableProtocol);
    __block id result;
    EXP_expect(^{ result = [AppleGuice instanceForProtocol:protocol]; }).notTo.raiseAny();
    
    [result verify];
}

-(void) test_instanceForClass_InitClassWithProtocolsAndMockCreationPolicy_returnsInstances {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    Protocol* protocol = @protocol(TestInjectableProtocol);
    __block NSArray* result;
    
    EXP_expect(^{ result = [AppleGuice allInstancesForProtocol:protocol]; }).notTo.raiseAny();
    
    EXP_expect(result).notTo.beNil;
    EXP_expect([result count]).to.equal(1);
    
    [result[0] verify];
}

//singleton

-(void) test_instanceForClass_InitSingletonClassWithInstanceForClassAndMockCreationPolicy_returnsInstance {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    __block id result1, result2;
    EXP_expect(^{ result1 = [AppleGuice instanceForClass:[TestInjectableSingletonClass class]]; result2 = [AppleGuice instanceForClass:[TestInjectableSingletonClass class]]; }).notTo.raiseAny();
    
    [result1 verify];
    [result2 verify];
    EXP_expect([result1 hash]).to.equal([result2 hash]);
}

-(void) test_instanceForClass_InitSingletonClassWithInstanceForClassShorthandAndMockCreationPolicy_returnsInstance {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    __block id result1, result2;
    EXP_expect(^{
        
        result1 = [AppleGuice instanceForClass:[TestInjectableSingletonClass class]];
        result2 = [AppleGuice instanceForClass:[TestInjectableSingletonClass class]]; }).notTo.raiseAny();
    
    [result1 verify];
    [result2 verify];
    EXP_expect([result1 hash]).to.equal([result2 hash]);
}

-(void) test_instanceForClass_InitSingletonClassWithProtocolAndMockCreationPolicy_returnsInstance {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    Protocol* protocol = @protocol(TestProtocolForSingletonClasses);
    __block id result1, result2;
    EXP_expect(^{ result1 = [AppleGuice instanceForProtocol:protocol];
        result2 = [AppleGuice instanceForProtocol:protocol]; }).notTo.raiseAny();
    
    [result1 verify];
    [result2 verify];
    EXP_expect([result1 hash]).toNot.equal([result2 hash]);
}

-(void) test_instanceForClass_InitSingletonClassWithProtocolsAndMockCreationPolicy_returnsInstances {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    Protocol* protocol = @protocol(TestProtocolForSingletonClasses);
    __block id result1;
    __block NSArray* result2;
    EXP_expect(^{ result1 = [AppleGuice instanceForProtocol:protocol];
        result2 = [AppleGuice allInstancesForProtocol:protocol]; }).notTo.raiseAny();
    
    EXP_expect([result2 count]).to.equal(1);
    [result1 verify];
    [result2[0] verify];
    EXP_expect([result1 hash]).toNot.equal([result2[0] hash]);
}

#pragma mark - validators

-(void) validateInjectedIvarsAreProxies:(AppleGuiceSanityTestClass*) result {
    EXP_expect([result isProxy]).to.beFalsy();
    EXP_expect([result.test_standAloneClass isProxy]).to.beTruthy();
    EXP_expect([result.test_standAloneClassInSuperClass isProxy]).to.beTruthy();
    EXP_expect([result.test_classFromProtocol isProxy]).to.beTruthy();
    EXP_expect([result.test_classFromSuperProtocol isProxy]).to.beTruthy();
    EXP_expect([result.test_TestInjectableProtocol isProxy]).to.beTruthy();
    EXP_expect([result.test_TestInjectableSuperProtocol isProxy]).to.beTruthy();
}

-(void) validateInjectedIvarInInstance:(AppleGuiceSanityTestClass*) result areEqualToInjectedIvarsInInstance: (AppleGuiceSanityTestClass*) secondResult {
    EXP_expect(result).notTo.equal(secondResult);
    EXP_expect(result.test_standAloneClass).to.equal(secondResult.test_standAloneClass);
    EXP_expect(result.test_standAloneClassInSuperClass).to.equal(secondResult.test_standAloneClassInSuperClass);
    EXP_expect(result.test_classFromProtocol).to.equal(secondResult.test_classFromProtocol);
    EXP_expect(result.test_classFromSuperProtocol).to.equal(secondResult.test_classFromSuperProtocol);
    EXP_expect(result.test_TestInjectableProtocol).to.equal(secondResult.test_TestInjectableProtocol);
    EXP_expect(result.test_TestInjectableSuperProtocol).to.equal(secondResult.test_TestInjectableSuperProtocol);
    EXP_expect([result.test_TestInjectableProtocol objectAtIndex:0]).to.equal([secondResult.test_TestInjectableProtocol objectAtIndex:0]);
    EXP_expect([result.test_TestInjectableProtocol objectAtIndex:1]).to.equal([secondResult.test_TestInjectableProtocol objectAtIndex:1]);
}

-(void) validateTestClassIntegrity:(AppleGuiceSanityTestClass*) result {
    EXP_expect(result).to.beInstanceOf([AppleGuiceSanityTestClass class]);
    EXP_expect(result.test_standAloneClass).to.beInstanceOf([TestInjectableClass class]);
    EXP_expect(result.test_standAloneClassInSuperClass).to.beInstanceOf([TestInjectableSuperClass class]);
    EXP_expect(result.test_classFromProtocol).to.conformTo(@protocol(TestInjectableSuperProtocol));
    EXP_expect(result.test_classFromSuperProtocol).to.conformTo(@protocol(TestInjectableSuperProtocol));
    EXP_expect(result.test_TestInjectableProtocol).to.beKindOf(NSClassFromString(@"__NSArrayI"));
    EXP_expect(result.test_TestInjectableSuperProtocol).to.beKindOf(NSClassFromString(@"__NSArrayI"));
    EXP_expect([result.test_TestInjectableProtocol count]).to.equal(2);
    EXP_expect([result.test_TestInjectableSuperProtocol count]).to.equal(2);
    
    NSArray* implementations = @[[TestInjectableProtocolImplementor class], [AnotherTestInjectableProtocolImplementor class]];
    
    EXP_expect(implementations).to.contain([[result.test_TestInjectableProtocol objectAtIndex:0] class]);
    EXP_expect(implementations).to.contain([[result.test_TestInjectableProtocol objectAtIndex:1] class]);
    EXP_expect(implementations).to.contain([[result.test_TestInjectableSuperProtocol objectAtIndex:0] class]);
    EXP_expect(implementations).to.contain([[result.test_TestInjectableSuperProtocol objectAtIndex:1] class]);
}

@end

@implementation TestInjectableClass
-(void)test {};
@end;
Implementation(TestInjectableSuperClass)
Implementation(TestInjectableProtocolImplementor)
Implementation(AnotherTestInjectableProtocolImplementor)
Implementation(AppleGuiceSanityTestClass)
Implementation(AppleGuiceSanityTestSuperClass)
Implementation(TestInjectableSingletonClass)
