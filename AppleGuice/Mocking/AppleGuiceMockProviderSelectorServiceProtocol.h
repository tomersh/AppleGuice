//
//  AppleGuiceMockProviderSelectorServiceProtocol.h
//  AppleGuice
//
//  Created by Tomer Shiri on 25/11/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceMockProviderProtocol.h"

@protocol AppleGuiceMockProviderSelectorServiceProtocol <NSObject>


-(void) setMockProviders:(NSArray *)mockProviders;

-(id<AppleGuiceMockProviderProtocol>) getSelectedMockProvider;

@end
