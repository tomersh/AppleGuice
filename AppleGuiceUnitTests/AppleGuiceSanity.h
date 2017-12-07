//
//  AppleGuiceSanity.h
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/10/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "TestBase.h"
#import "AppleGuiceInjectable.h"
#import "Appleguicesingleton.h"

@protocol TestInjectableSuperProtocol <AppleGuiceInjectable>
@end

@protocol TestInjectableProtocol <TestInjectableSuperProtocol>
@end

@protocol TestProtocolForSingletonClasses <NSObject>
@end

@interface TestInjectableProtocolImplementor : NSObject<TestInjectableProtocol>
@end

@interface AnotherTestInjectableProtocolImplementor : NSObject<TestInjectableProtocol>
@end

@interface TestInjectableSuperClass : NSObject<AppleGuiceInjectable>
@end

@interface TestInjectableSingletonClass : NSObject<AppleGuiceInjectable, AppleGuiceSingleton, TestProtocolForSingletonClasses>
@end

@interface TestInjectableClass : TestInjectableSuperClass
-(void) test;
@end

@interface AppleGuiceSanityTestSuperClass : NSObject<AppleGuiceInjectable>
    iocIvar(TestInjectableSuperClass, standAloneClassInSuperClass);
    iocProtocol(TestInjectableSuperProtocol, classFromSuperProtocol);
    iocIvar(NSArray, TestInjectableProtocol);
@end

@interface AppleGuiceSanityTestClass : AppleGuiceSanityTestSuperClass
    iocIvar(TestInjectableClass, standAloneClass);
    iocProtocol(TestInjectableProtocol, classFromProtocol);
    iocIvar(NSArray, TestInjectableSuperProtocol);
@end


@interface AppleGuiceSanity : TestBase

@end
