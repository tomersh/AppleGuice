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

#define INVALID_CLASS_NAME @"abcdefg#"
#define INVALID_PROTOCOL_NAME @"abcdefg#"


@interface TestBase : SenTestCase {
    @package
    BOOL yes;
    BOOL no;
}



@end
