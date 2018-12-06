//
//  AppleGuiceSwiftProtocolDemangler.m
//  AppleGuice
//
//  Created by Alex on 17/03/2018.
//  Copyright © 2018 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceSwiftProtocolDemangler.h"

NSString* const swiftProtocolPrefix = @"_TtP";

@implementation AppleGuiceSwiftProtocolDemangler

- (BOOL)shouldDemangleProtocolWithName:(NSString *)protocolName {
    return [protocolName containsString:swiftProtocolPrefix];
}

- (NSString *)demangledSwiftProtocol:(NSString *)protocolName {
    //Swift File Format and ABI - https://pewpewthespells.com/blog/swiftdoc_and_swiftmodule_file_format_(beta_1).html
    //Structure of Non-Swift namespace: _TtP(namespace name length)(namespace name)(protocol name length)(protocol name)_
    
    //If the protocol name doesn't start with _TtP - This can't be demangled so bail out
    if ([protocolName rangeOfString:swiftProtocolPrefix].location != 0) {
        return nil;
    }
    NSString *tempProtocol = [protocolName stringByReplacingOccurrencesOfString:swiftProtocolPrefix withString:@""];
    NSUInteger namespaceLength = 0;
    NSUInteger index = 0;
    
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    //Find the namespace length
    while ([[tempProtocol substringWithRange:NSMakeRange(index, 1)] rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        namespaceLength = namespaceLength * 10 + [[tempProtocol substringWithRange:NSMakeRange(index, 1)] integerValue];
        index++;
    }
    
    if (!index) { //No digits - meaning bad format - bail out!
        return nil;
    }
    
    NSString *namespace = [tempProtocol substringWithRange:NSMakeRange(index, namespaceLength)];
    
    tempProtocol = [tempProtocol substringFromIndex:namespaceLength + index];
    
    //Find the protocol name length
    index = 0;
    NSUInteger protocolLength = 0;

    while ([[tempProtocol substringWithRange:NSMakeRange(index, 1)] rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        protocolLength = protocolLength * 10 + [[tempProtocol substringWithRange:NSMakeRange(index, 1)] integerValue];
        index++;
    }
    
    if (!index) { //No digits - meaning bad format - bail out!
        return nil;
    }
    
    tempProtocol = [tempProtocol substringWithRange:NSMakeRange(index, tempProtocol.length - index - 1)];
    
    //If protocol length doesn't equal the actual remaing string length - meaning bad format - bail out!
    if (tempProtocol.length != protocolLength) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@.%@", namespace, tempProtocol];
}

@end
