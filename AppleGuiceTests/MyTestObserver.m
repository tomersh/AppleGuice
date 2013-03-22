//
//  MyTestObserver.m
//  AppleGuice
//
//  Created by Tomer Shiri on 3/22/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "MyTestObserver.h"

@implementation MyTestObserver
+(void)initialize {
    [[NSUserDefaults standardUserDefaults] setValue:@"MyTestObserver" forKey:@"SenTestObserverClass"];
    [super initialize];
}

+(void) testSuiteDidStart:(NSNotification *) aNotification {
    NSLog(@"Test suit Started");
}
+(void) testSuiteDidStop:(NSNotification *) aNotification {
    NSLog(@"Test suit ended");
}
+(void) testCaseDidStart:(NSNotification *) aNotification {
    NSLog(@"Test Started");
}
+(void) testCaseDidStop:(NSNotification *) aNotification {
    NSLog(@"Test Stopped");
}
+(void) testCaseDidFail:(NSNotification *) aNotification {
    NSLog(@"Test failed");
}

@end
