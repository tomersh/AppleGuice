//
//  AppleGuiceAutoInjectorTests.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/9/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceAutoInjectorTests.h"
#import "AppleGuiceAutoInjector.h"
#import "AppleGuiceInjectorProtocol.h"

//OCMock doesn't play well when swizzeling constructors.

@interface MockedInjector : NSObject<AppleGuiceInjectorProtocol> {
    @public
    BOOL didCallInjector;
    id calledArg;
}
-(void) reset;
@end

@implementation AppleGuiceAutoInjectorTests {
    
}

static MockedInjector* mockedInjector;

+(void)initialize {
    mockedInjector = [[MockedInjector alloc] init];
    [AppleGuiceAutoInjector setInjector:mockedInjector];
}

-(void)setUp {
    [super setUp];
    [mockedInjector reset];
}

-(void)tearDown {
    [super tearDown];
    [AppleGuiceAutoInjector stopAutoInjector]; //just in case
}

-(void) test__startAutoInjector__call__startsTheService {
    Class injectedClassType = [NSArray class];
    [AppleGuiceAutoInjector startAutoInjector];
    
    __block id result;
    EXP_expect(^{ result = [[[injectedClassType alloc] init] autorelease]; }).toNot.raiseAny();
    EXP_expect(result).to.beInstanceOf(injectedClassType);
    EXP_expect(mockedInjector->didCallInjector).to.beTruthy();
    EXP_expect(mockedInjector->calledArg).to.equal(result);
}

-(void) test__stopAutoInjector__call__stopsTheService {
    Class injectedClassType = [NSArray class];
    
    [AppleGuiceAutoInjector startAutoInjector];
    [AppleGuiceAutoInjector stopAutoInjector];

    __block id result;
    EXP_expect(^{ result = [[[injectedClassType alloc] init] autorelease]; }).toNot.raiseAny();
    
    EXP_expect(result).to.beInstanceOf(injectedClassType);
    EXP_expect(mockedInjector->didCallInjector).to.beFalsy();
}

-(void) test__startAutoInjector__callTwice__serviceIsWorkingProperly {
    [AppleGuiceAutoInjector startAutoInjector];
    [self test__startAutoInjector__call__startsTheService];
}

-(void) test__stopsAutoInjector__callTwice__serviceIsWorkingProperly {
    Class injectedClassType = [NSArray class];
    
    [AppleGuiceAutoInjector startAutoInjector];
    [AppleGuiceAutoInjector stopAutoInjector];
    [AppleGuiceAutoInjector stopAutoInjector];
    
    __block id result;
    EXP_expect(^{ result = [[[injectedClassType alloc] init] autorelease]; }).toNot.raiseAny();
    
    EXP_expect(result).to.beInstanceOf(injectedClassType);
    EXP_expect(mockedInjector->didCallInjector).to.beFalsy();
}
@end

@implementation MockedInjector

-(id)init {
    self = [super init];
    if (!self) return self;
    [self reset];
    return self;
}

-(void) reset {
    didCallInjector = NO;
    [calledArg release];
    calledArg = nil;
}

-(void)injectImplementationsToInstance:(id<NSObject>)classInstance {
    didCallInjector = YES;
    [calledArg release];
    calledArg = [classInstance retain];
}

@end