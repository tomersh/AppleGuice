//
//  AppleGuiceClassGeneratorTests.m
//  AppleGuice
//
//  Created by Tomer Shiri on 5/8/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "TestBase.h"
#import "AppleGuiceClassGenerator.h"

@interface AppleGuiceClassGeneratorTests : TestBase

@end

@implementation AppleGuiceClassGeneratorTests {
    AppleGuiceClassGenerator* serviceUnderTest;
}

- (void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceClassGenerator alloc] init];
}

- (void)tearDown
{
    [serviceUnderTest release];
    [super tearDown];
}

-(void) test_safeGetClassesFromStrings_nilPassed_returnsEmptyArray {
    NSArray* classesAsStrings = nil;
    
    
    NSArray* result = [serviceUnderTest safeGetClassesFromStrings:classesAsStrings];
    
    
    EXP_expect(result).notTo.beNil;
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_safeGetClassesFromStrings_emptyArrayPassed_returnsEmptyArray {
    NSArray* classesAsStrings = @[];
    
    
    NSArray* result = [serviceUnderTest safeGetClassesFromStrings:classesAsStrings];
    
    
    EXP_expect(result).notTo.beNil;
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_safeGetClassesFromStrings_validClass_returnsAnArrayContainingClass {
    NSArray* classesAsStrings = @[ @"NSSet" ];
    
    
    NSArray* result = [serviceUnderTest safeGetClassesFromStrings:classesAsStrings];
    
    
    EXP_expect(result).notTo.beNil;
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect([result count]).to.equal(1);
    EXP_expect(result[0]).to.equal(NSClassFromString(classesAsStrings[0]));
}

-(void) test_safeGetClassesFromStrings_invalidClass_returnsEmptyArray {
    NSArray* classesAsStrings = @[ INVALID_CLASS_NAME ];
    
    
    NSArray* result = [serviceUnderTest safeGetClassesFromStrings:classesAsStrings];
    
    
    EXP_expect(result).notTo.beNil;
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_safeGetClassesFromStrings_mixOfValidAndInvalidClassesNames_returnsClassesOfValidNamesOnly {
    NSArray* classesAsStrings = @[ @"NSSet", INVALID_CLASS_NAME, @"NSArray", @"NSDictionary" ];
    
    
    NSArray* result = [serviceUnderTest safeGetClassesFromStrings:classesAsStrings];
    
    
    EXP_expect(result).notTo.beNil;
    EXP_expect(result).to.beKindOf([NSArray class]);
    EXP_expect([result count]).to.equal(3);
    EXP_expect(result).to.contain(NSClassFromString(classesAsStrings[0]));
    EXP_expect(result).to.contain(NSClassFromString(classesAsStrings[2]));
    EXP_expect(result).to.contain(NSClassFromString(classesAsStrings[3]));
}

@end
