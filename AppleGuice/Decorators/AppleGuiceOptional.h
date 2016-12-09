//
//  AppleGuiceOptional.h
//  AppleGuice
//
//  Created by Tomer Shiri on 2/20/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AppleGuiceOptional <NSObject>

//This is a flag.
//When a protocol is marked with AppleGuiceOptional, AppleGuice will not throw an AppleGuiceInjectableImplementationNotFoundException
//if the implementation of the protocol was not found during injection.

@end
