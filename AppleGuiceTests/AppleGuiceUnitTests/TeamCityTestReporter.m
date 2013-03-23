//
//  MyTestObserver.m
//  AppleGuice
//
//  Created by Tomer Shiri on 3/22/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//

#import "TeamCityTestReporter.h"

@implementation TeamCityTestReporter
+(void)initialize {
    [[NSUserDefaults standardUserDefaults] setValue:@"TeamCityTestReporter" forKey:@"SenTestObserverClass"];
    [super initialize];
}

+ (void) testSuiteDidStart:(NSNotification *)aNotification
{
    
    NSString* suiteName = [aNotification.test.name hasPrefix:@"/"] ? [aNotification.test.name lastPathComponent] : aNotification.test.name;
    
    if (![suiteName hasSuffix:@".octest(Tests)"])
        return;
    
    testlog([NSString stringWithFormat:@"##teamcity[testSuiteStarted name='%@']", escapeForTeamcity(suiteName)]);
}

+ (void) testSuiteDidStop:(NSNotification *)aNotification
{
    NSString* suiteName = [aNotification.test.name hasPrefix:@"/"] ? [aNotification.test.name lastPathComponent] : aNotification.test.name;
    
    if (![suiteName hasSuffix:@".octest(Tests)"])
        return;
    
    testlog([NSString stringWithFormat:@"##teamcity[testSuiteFinished name='%@']", escapeForTeamcity(suiteName)]);
}

+ (void) testCaseDidStart:(NSNotification *)aNotification
{
    testlog([NSString stringWithFormat:@"##teamcity[testStarted name='%@' captureStandardOutput='true']", teamCityTestName(aNotification.test.name)]);
}

+ (void) testCaseDidStop:(NSNotification *)aNotification
{
    testlog([NSString stringWithFormat:@"##teamcity[testFinished name='%@' duration='%f']", teamCityTestName(aNotification.test.name), aNotification.run.testDuration]);
}

+ (void) testCaseDidFail:(NSNotification *)aNotification
{
    testlog([NSString stringWithFormat:@"##teamcity[testFailed name='%@' message='%@' details='%@']",
             teamCityTestName(aNotification.test.name),
             escapeForTeamcity([[aNotification exception] description]),
             @""]);
}

static void testlog (NSString *message)
{
	NSString *line = [NSString stringWithFormat:@"%@\n", message];
	[(NSFileHandle *)[NSFileHandle fileHandleWithStandardOutput] writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

static NSString* escapeForTeamcity (NSString *raw)
{
    raw = [raw stringByReplacingOccurrencesOfString:@"|" withString:@"||"];
    raw = [raw stringByReplacingOccurrencesOfString:@"'" withString:@"|'"];
    raw = [raw stringByReplacingOccurrencesOfString:@"\n" withString:@"|n"];
    raw = [raw stringByReplacingOccurrencesOfString:@"\r" withString:@"|r"];
    raw = [raw stringByReplacingOccurrencesOfString:@"[" withString:@"|["];
    raw = [raw stringByReplacingOccurrencesOfString:@"]" withString:@"|]"];
    
    return raw;
}

static NSString* teamCityTestName (NSString *raw)
{
    raw = [raw stringByReplacingOccurrencesOfString:@" " withString:@"."];
    return escapeForTeamcity(raw);
}

@end
