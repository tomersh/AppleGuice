//
//  TestBase.h
//  AppleGuice
//
//  Created by Tomer Shiri on 3/20/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMock.h"
#import "Expecta.h"

#define INVALID_CLASS_NAME @"abcdefg#"
#define INVALID_PROTOCOL_NAME @"abcdefg#"

#define testIocPrefix @"_test_"
#define iocIvar(__clazz, __name) @property(nonatomic, retain) __clazz* test_##__name
#define iocPrimitive(__type, __name) @property(nonatomic, assign) __type test_##__name
#define iocProtocol(__type, __name) @property(nonatomic, retain) id<__type> test_##__name

#define OCMArgOfKind(__clazz) [OCMArg checkWithBlock:^BOOL(id object) { return [object isKindOfClass:__clazz]; }]

@interface TestBase : XCTestCase {
    @package
    BOOL yes;
    BOOL no;
}



@end
