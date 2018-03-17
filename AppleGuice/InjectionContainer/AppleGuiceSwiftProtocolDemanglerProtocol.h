//
//  AppleGuiceSwiftProtocolDemanglerProtocol.h
//  AppleGuice
//
//  Created by Alex on 17/03/2018.
//  Copyright © 2018 Tomer Shiri. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const swiftProtocolPrefix;

@protocol AppleGuiceSwiftProtocolDemanglerProtocol <NSObject>

- (BOOL)shouldDemangleProtocolWithName:(NSString *)protocolName;

- (NSString *)demangledSwiftProtocol:(NSString *)protocolName;

@end
