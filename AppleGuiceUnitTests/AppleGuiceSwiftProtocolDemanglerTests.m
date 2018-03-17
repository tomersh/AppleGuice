//
//  AppleGuiceSwiftProtocolDemanglerTests.m
//  AppleGuiceUnitTests
//
//  Created by Alex on 17/03/2018.
//  Copyright © 2018 Tomer Shiri. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AppleGuiceSwiftProtocolDemangler.h"
#import "Expecta.h"

@interface AppleGuiceSwiftProtocolDemanglerTests : XCTestCase

@end

@implementation AppleGuiceSwiftProtocolDemanglerTests {
    AppleGuiceSwiftProtocolDemangler *serviceUnderTest;
}

- (void)setUp {
    [super setUp];
    
    serviceUnderTest = [[AppleGuiceSwiftProtocolDemangler alloc] init];
}

- (void)tearDown {
    [serviceUnderTest release];
    serviceUnderTest = nil;
    [super tearDown];
}

- (void)test_shouldDemangleProtocolWithName_swiftProtocolName_returnTrue {
    
    BOOL res = [serviceUnderTest shouldDemangleProtocolWithName:[self _mangledDummyProtocolName]];
    
    
    EXP_expect(res).to.beTruthy();
}

- (void)test_shouldDemangleProtocolWithName_objcProtocolName_returnFalse {
    
    BOOL res = [serviceUnderTest shouldDemangleProtocolWithName:[self _dummyProtocol]];

    EXP_expect(res).to.beFalsy();
}

- (void)test_demangledSwiftProtocol_swiftProtocol_returnTheDemangledName {

    NSString *protocolName = [self _mangledDummyProtocolName];
    
    NSString *demangledProtocolName = [serviceUnderTest demangledSwiftProtocol:protocolName];
    
    EXP_expect(demangledProtocolName).to.equal([NSString stringWithFormat:@"%@.%@", [self _dummySwiftNamespace], [self _dummyProtocol]]);
}

- (void)test_demangledSwiftProtocol_objProtocol_returnNil {
    NSString *demangeldProtocolName = [serviceUnderTest demangledSwiftProtocol:[self _dummyProtocol]];
    
    EXP_expect(demangeldProtocolName).to.beNil();
}

- (void)test_demangledSwiftProtocol_noCountForNamespace_returnNil {
    NSString *protocolName = [NSString stringWithFormat:@"%@%@%ld%@_", swiftProtocolPrefix, [self _dummySwiftNamespace], [self _dummyProtocol].length, [self _dummyProtocol]];
    
    
    NSString *demangeldProtocolName = [serviceUnderTest demangledSwiftProtocol:protocolName];
    
    
    EXP_expect(demangeldProtocolName).to.beNil();

}

- (void)test_demangledSwiftProtocol_noCountForProtocol_returnNil {
    NSString *protocolName = [NSString stringWithFormat:@"%@%ld%@%@_", swiftProtocolPrefix, [self _dummySwiftNamespace].length, [self _dummySwiftNamespace], [self _dummyProtocol]];
    
    
    NSString *demangeldProtocolName = [serviceUnderTest demangledSwiftProtocol:protocolName];
    
    
    EXP_expect(demangeldProtocolName).to.beNil();
    
}

- (void)test_demangledSwiftProtocol_wrongCountForProtocol_returnNil {
    NSString *protocolName = [NSString stringWithFormat:@"%@%ld%@%ld%@_", swiftProtocolPrefix, [self _dummySwiftNamespace].length, [self _dummySwiftNamespace], [self _dummyProtocol].length - 1, [self _dummyProtocol]];
    
    
    NSString *demangeldProtocolName = [serviceUnderTest demangledSwiftProtocol:protocolName];
    
    
    EXP_expect(demangeldProtocolName).to.beNil();
    
}

- (NSString *)_mangledDummyProtocolName {
    NSString *namespace = [self _dummySwiftNamespace];
    NSString *protocol = [self _dummyProtocol];
    
    return [NSString stringWithFormat:@"%@%ld%@%ld%@_", swiftProtocolPrefix, namespace.length, namespace, protocol.length, protocol];
}
                
- (NSString *)_dummySwiftNamespace {
    return @"MyDynamicFramework";
}

- (NSString *)_dummyProtocol {
    return @"MyProtocol";
}

@end
