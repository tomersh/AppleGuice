//
//  AppleGuiceOCMockitoMockProvider.m
//  AppleGuice
//
//  Created by Tomer Shiri on 25/11/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceOCMockitoMockProvider.h"

@implementation AppleGuiceOCMockitoMockProvider


-(id) init {
    self = [super initWithClassMockClassName:@"MKTObjectMock" andProtocolMockClassName:@"MKTProtocolMock"];
    if (!self) return self;
    self.mockProtocolSelector = @selector(mockForProtocol:);
    self.mockClassSelector = @selector(mockForClass:);
    return self;
}

@end
