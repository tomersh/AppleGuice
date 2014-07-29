//
//  TestBase.m
//  AppleGuice
//
//  Created by Tomer Shiri on 3/20/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "TestBase.h"
#include <stdio.h>

//extern void __gcov_flush(void);

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
//    __gcov_flush();
    
    [super tearDown];
}

@end
