//
//  TestBase.m
//  AppleGuice
//
//  Created by Tomer Shiri on 3/20/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "TestBase.h"
#include <stdio.h>

#ifdef GCC_GENERATE_TEST_COVERAGE_FILES
extern void __gcov_flush();
#endif

@implementation TestBase

- (void)setUp
{
    [super setUp];
    yes = YES;
    no = NO;
    // Set-up code here.
}

- (void)tearDown
{
#ifdef GCC_GENERATE_TEST_COVERAGE_FILES
    __gcov_flush();
#endif
    [super tearDown];
}

@end
