//
//  EXPMatchers+conformsToProtocol.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 4/12/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "EXPMatchers+conformsToProtocol.h"

EXPMatcherImplementationBegin(conformToProtocol, (Protocol* expected)) {
    BOOL actualIsNil = (actual == nil);
    BOOL expectedIsNil = (expected == nil);
    
    prerequisite(^BOOL{
        return !(actualIsNil || expectedIsNil);
        // Return `NO` if matcher should fail whether or not the result is inverted using `.Not`.
    });
    
    match(^BOOL{
        return [actual conformsToProtocol:expected];
    });
    
    failureMessageForTo(^NSString *{
        if(actualIsNil) return @"the actual value is nil/null";
        if(expectedIsNil) return @"the expected value is nil/null";
        return [NSString stringWithFormat:@"%@ should conform to protocol %@",
                NSStringFromClass([actual class]), NSStringFromProtocol(expected)];
        // Return the message to be displayed when the match function returns `YES`.
    });
    
    failureMessageForNotTo(^NSString *{
        if(actualIsNil) return @"the actual value is nil/null";
        if(expectedIsNil) return @"the expected value is nil/null";
        return [NSString stringWithFormat:@"expected: not a kind of %@, "
                "got: an instance of %@, which conforms to protocol %@",
                NSStringFromProtocol(expected), NSStringFromClass([actual class]), NSStringFromProtocol(expected)];
        // Return the message to be displayed when the match function returns `NO`.
    });
}
EXPMatcherImplementationEnd
