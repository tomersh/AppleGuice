//
//  AppleGuiceMockProvider.m
//  AppleGuice
//
//  Created by Tomer Shiri on 25/11/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceMockProvider.h"

@implementation AppleGuiceMockProvider {
    Class _classMockClassName;
    Class _protocolMockClassName;
}

-(instancetype) initWithClassMockClassName:(NSString*) classMockClassName andProtocolMockClassName:(NSString*) protocolMockClassName {
    self = [super init];
    if (!self) return self;
    _classMockClassName = NSClassFromString(classMockClassName);
    _protocolMockClassName = NSClassFromString(protocolMockClassName);
    return self;
}

-(id) mockForClass:(Class)aClass {
    if (![self isServiceAvailable]) return nil;
    if (aClass == nil) return nil;
    return [_classMockClassName performSelector:self.mockClassSelector withObject:aClass];
}

-(id) mockForProtocol:(Protocol *)aProtocol {
    if (![self isServiceAvailable]) return nil;
    if (aProtocol == nil) return nil;
    return [_protocolMockClassName performSelector:self.mockProtocolSelector withObject:aProtocol];
}

-(BOOL) isServiceAvailable {
    return _classMockClassName != nil && _protocolMockClassName != nil;
}

@end
