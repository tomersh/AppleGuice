//
//  TestBase.h
//  AppleGuice
//
//  Created by Tomer Shiri on 3/20/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "OCMock.h"
#import "Expecta.h"
#import "EXPMatchers+conformsToProtocol.h"

#define INVALID_CLASS_NAME @"abcdefg#"
#define INVALID_PROTOCOL_NAME @"abcdefg#"

#define testIocPrefix @"test_"
#define iocIvar(__clazz, __name) __clazz* test_##__name
#define iocPrimitive(__type, __name) __type test_##__name
#define iocProtocol(__type, __name) id<__type> test_##__name

@interface TestBase : SenTestCase {
    @package
    BOOL yes;
    BOOL no;
}



@end
