//
//  AppleGuiceProtocolLocatorTests.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/1/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceProtocolLocatorTests.h"
#import "AppleGuiceProtocolLocator.h"
#import "AppleGuiceBindingServiceProtocol.h"

@implementation AppleGuiceProtocolLocatorTests {
    AppleGuiceProtocolLocator* protocolLocator;
    id bindingService;
}


-(void)setUp {
    [super setUp];
    protocolLocator = [[AppleGuiceProtocolLocator alloc] init];
    bindingService = [OCMockObject mockForProtocol:@protocol(AppleGuiceBindingServiceProtocol)];
    protocolLocator.bindingService = bindingService;
}

-(void)tearDown {
    [protocolLocator release];
    protocolLocator = nil;
    [super tearDown];
}

/*
 -(void) bootstrapAutomaticImplementationDiscovery;
 
 -(NSArray*) getAllClassesByProtocolType:(Protocol*) protocol;
 
 -(void) setFilterProtocol:(Protocol*) filterProtocol;
 */


@end
