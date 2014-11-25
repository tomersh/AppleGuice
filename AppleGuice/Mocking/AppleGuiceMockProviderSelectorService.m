//
//  AppleGuiceMockProviderSelectorService.m
//  AppleGuice
//
//  Created by Tomer Shiri on 25/11/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceMockProviderSelectorService.h"

@implementation AppleGuiceMockProviderSelectorService {
    id<AppleGuiceMockProviderProtocol> _selectedMockProvider;
}


-(void)setMockProviders:(NSArray *)mockProviders {
    [self _selectMockProvider:mockProviders];
}

-(id<AppleGuiceMockProviderProtocol>) getSelectedMockProvider {
    return _selectedMockProvider;
}

-(void) _selectMockProvider:(NSArray*) mockProviders {
    for (id<AppleGuiceMockProviderProtocol> mockProvider in mockProviders) {
        if ([mockProvider isServiceAvailable]) {
            [_selectedMockProvider release];
            _selectedMockProvider = [mockProvider retain];
            break;
        }
    }
}


-(void)dealloc {
    [_selectedMockProvider release];
    [super dealloc];
}

@end
