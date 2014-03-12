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

@interface AppleGuiceSanityTestSuperClass : NSObject{
    @public
    iocIvar(TestInjectableSuperClass, standAloneClassInSuperClass);
    iocProtocol(TestInjectableSuperProtocol, classFromSuperProtocol);
    iocIvar(NSArray, TestInjectableProtocol);
}
@end

@interface AppleGuiceSanityTestClass : AppleGuiceSanityTestSuperClass {
    @public
    iocIvar(TestInjectableClass, standAloneClass);
    iocProtocol(TestInjectableProtocol, classFromProtocol);
    iocIvar(NSArray, TestInjectableSuperProtocol);
}
@end

@implementation AppleGuiceSanity

-(void)setUp {
    [super setUp];
    [AppleGuice stopService];
    [AppleGuice setIocPrefix:testIocPrefix];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyDefault];
}

-(void)tearDown {
    [super tearDown];
    [AppleGuice stopService];
}

#pragma mark - pre compile discovery policy

-(void) test__instanceForClass__ComplexObjectInitializedWithDefaultPolicies__AllFieldsAreInjected {
    [AppleGuice startService];
    __block AppleGuiceSanityTestClass* result;
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];

}

-(void) test__instanceForClass__ComplexObjectInitializedWithSingletonCreationPolicy__allIvarsAreInjectedWithSingletons {
    [AppleGuice startService];
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
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad];
    __block AppleGuiceSanityTestClass* result;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateInjectedIvarsAreProxies:result];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadAndSingletonsCreationPolicy__allIvarsAreInjectedWithProxies {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad | AppleGuiceInstanceCreationPolicySingletons];
    __block AppleGuiceSanityTestClass* result;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateInjectedIvarsAreProxies:result];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadAndSingletonsCreationPolicy__proxiesAreConvertedToSingletons {
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad | AppleGuiceInstanceCreationPolicySingletons];
    AppleGuiceSanityTestClass* result = [[AppleGuiceSanityTestClass alloc] init];
    AppleGuiceSanityTestClass* secondResult = [[AppleGuiceSanityTestClass alloc] init];
    
    id generatedObject1 = ((AppleGuiceInvocationProxy*)result->test_standAloneClass).createInstanceBlock();
    id generatedObject2 = ((AppleGuiceInvocationProxy*)secondResult->test_standAloneClass).createInstanceBlock();
    
    EXP_expect(generatedObject1).to.equal(generatedObject2);
}

#pragma mark - runtime discovery policy

-(void) test__instanceForClass__ComplexObjectInitializedWithRuntimeImplementationDiscoveryPolicy__AllFieldsAreInjected {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyRuntime];
    __block AppleGuiceSanityTestClass* result;
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    
}

-(void) test__instanceForClass__ComplexObjectInitializedWithSingletonCreationPolicyAndImplementationAutoDiscovery__allIvarsAreInjectedWithSingletons {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyRuntime];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicySingletons];
    __block AppleGuiceSanityTestClass* result;
    __block AppleGuiceSanityTestClass* secondResult;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    EXP_expect(^{ secondResult = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateTestClassIntegrity:secondResult];
    [self validateInjectedIvarInInstance:result areEqualToInjectedIvarsInInstance:secondResult];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadCreationPolicyAndImplementationAutoDiscovery__allIvarsAreInjectedWithProxies {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyRuntime];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad];
    __block AppleGuiceSanityTestClass* result;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateInjectedIvarsAreProxies:result];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadAndSingletonsCreationPolicyAndImplementationAutoDiscovery__allIvarsAreInjectedWithProxies {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyRuntime];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad | AppleGuiceInstanceCreationPolicySingletons];
    __block AppleGuiceSanityTestClass* result;
    
    EXP_expect(^{ result = [[AppleGuiceSanityTestClass alloc] init]; }).notTo.raiseAny();
    
    [self validateTestClassIntegrity:result];
    [self validateInjectedIvarsAreProxies:result];
}

-(void) test__instanceForClass__ComplexObjectInitializedWithLazyLoadAndSingletonsCreationPolicyAndImplementationAutoDiscovery__proxiesAreConvertedToSingletons {
    [AppleGuice startServiceWithImplementationDiscoveryPolicy:AppleGuiceImplementationDiscoveryPolicyRuntime];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad | AppleGuiceInstanceCreationPolicySingletons];
    AppleGuiceSanityTestClass* result = [[AppleGuiceSanityTestClass alloc] init];
    AppleGuiceSanityTestClass* secondResult = [[AppleGuiceSanityTestClass alloc] init];
    
    id generatedObject1 = ((AppleGuiceInvocationProxy*)result->test_standAloneClass).createInstanceBlock();
    id generatedObject2 = ((AppleGuiceInvocationProxy*)secondResult->test_standAloneClass).createInstanceBlock();
    
    EXP_expect(generatedObject1).to.equal(generatedObject2);
}

#pragma mark - validators

-(void) validateInjectedIvarsAreProxies:(AppleGuiceSanityTestClass*) result {
    EXP_expect([result isProxy]).to.beFalsy();
    EXP_expect([result->test_standAloneClass isProxy]).to.beTruthy();
    EXP_expect([result->test_standAloneClassInSuperClass isProxy]).to.beTruthy();
    EXP_expect([result->test_classFromProtocol isProxy]).to.beTruthy();
    EXP_expect([result->test_classFromSuperProtocol isProxy]).to.beTruthy();
    EXP_expect([result->test_TestInjectableProtocol isProxy]).to.beTruthy();
    EXP_expect([result->test_TestInjectableSuperProtocol isProxy]).to.beTruthy();
}

-(void) validateInjectedIvarInInstance:(AppleGuiceSanityTestClass*) result areEqualToInjectedIvarsInInstance: (AppleGuiceSanityTestClass*) secondResult {
    EXP_expect(result).notTo.equal(secondResult);
    EXP_expect(result->test_standAloneClass).to.equal(secondResult->test_standAloneClass);
    EXP_expect(result->test_standAloneClassInSuperClass).to.equal(secondResult->test_standAloneClassInSuperClass);
    EXP_expect(result->test_classFromProtocol).to.equal(secondResult->test_classFromProtocol);
    EXP_expect(result->test_classFromSuperProtocol).to.equal(secondResult->test_classFromSuperProtocol);
    EXP_expect(result->test_TestInjectableProtocol).to.equal(secondResult->test_TestInjectableProtocol);
    EXP_expect(result->test_TestInjectableSuperProtocol).to.equal(secondResult->test_TestInjectableSuperProtocol);
    EXP_expect([result->test_TestInjectableProtocol objectAtIndex:0]).to.equal([secondResult->test_TestInjectableProtocol objectAtIndex:0]);
    EXP_expect([result->test_TestInjectableProtocol objectAtIndex:1]).to.equal([secondResult->test_TestInjectableProtocol objectAtIndex:1]);
}

-(void) validateTestClassIntegrity:(AppleGuiceSanityTestClass*) result {
    EXP_expect(result).to.beInstanceOf([AppleGuiceSanityTestClass class]);
    EXP_expect(result->test_standAloneClass).to.beInstanceOf([TestInjectableClass class]);
    EXP_expect(result->test_standAloneClassInSuperClass).to.beInstanceOf([TestInjectableSuperClass class]);
    EXP_expect(result->test_classFromProtocol).to.conformToProtocol(@protocol(TestInjectableSuperProtocol));
    EXP_expect(result->test_classFromSuperProtocol).to.conformToProtocol(@protocol(TestInjectableSuperProtocol));
    EXP_expect(result->test_TestInjectableProtocol).to.beKindOf(NSClassFromString(@"__NSArrayI"));
    EXP_expect(result->test_TestInjectableSuperProtocol).to.beKindOf(NSClassFromString(@"__NSArrayI"));
    EXP_expect([result->test_TestInjectableProtocol count]).to.equal(2);
    EXP_expect([result->test_TestInjectableSuperProtocol count]).to.equal(2);
    
    NSArray* implementations = @[[TestInjectableProtocolImplementor class], [AnotherTestInjectableProtocolImplementor class]];
    
    EXP_expect(implementations).to.contain([[result->test_TestInjectableProtocol objectAtIndex:0] class]);
    EXP_expect(implementations).to.contain([[result->test_TestInjectableProtocol objectAtIndex:1] class]);
    EXP_expect(implementations).to.contain([[result->test_TestInjectableSuperProtocol objectAtIndex:0] class]);
    EXP_expect(implementations).to.contain([[result->test_TestInjectableSuperProtocol objectAtIndex:1] class]);
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
