//
//  AppleGuiceMockProvider.h
//  AppleGuice
//
//  Created by Tomer Shiri on 25/11/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//


#import "AppleGuiceMockProviderProtocol.h"
#import "AppleGuiceClassGeneratorProtocol.h"

@interface AppleGuiceMockProvider : NSObject<AppleGuiceMockProviderProtocol>

@property (nonatomic, assign) SEL mockClassSelector;
@property (nonatomic, assign) SEL mockProtocolSelector;

@end
