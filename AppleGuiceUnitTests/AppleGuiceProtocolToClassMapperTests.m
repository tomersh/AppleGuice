//
//  AppleGuiceProtocolToClassMapperTests.m
//  AppleGuice
//
//  Created by Tomer Shiri on 5/8/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "TestBase.h"
#import "AppleGuiceProtocolToClassMapper.h"

@interface AppleGuiceProtocolToClassMapperTests : TestBase {
    AppleGuiceProtocolToClassMapper* classUnderTest;
}

@end

@implementation AppleGuiceProtocolToClassMapperTests

- (void)setUp
{
    [super setUp];
    classUnderTest = [[AppleGuiceProtocolToClassMapper alloc] init];
}

- (void)tearDown
{
    [classUnderTest release];
    [super tearDown];
}

-(void) test_setImplementations_nilClasses_doesNotSet {
    Protocol* protocol = @protocol(NSObject);
    
    
    [classUnderTest setImplementations:nil withProtocol:protocol];
    
    
    NSSet* result = [classUnderTest getClassesForProtocol:protocol];
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_setImplementations_emptyClasses_dosNotSet {
    Protocol* protocol = @protocol(NSObject);
    
    
    [classUnderTest setImplementations:@[] withProtocol:protocol];
    
    
    NSSet* result = [classUnderTest getClassesForProtocol:protocol];
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_setImplementations_nilProtocol_dosNotSet {
    Protocol* protocol = nil;
    
    
    [classUnderTest setImplementations:@[] withProtocol:protocol];
    
    
    EXP_expect([classUnderTest count]).to.equal(0);
}

-(void) test_setImplementations_validProtocolAndClasses_setsAndReturns {
    Protocol* protocol = @protocol(NSObject);
    

    [classUnderTest setImplementations:@[ [NSArray class] ] withProtocol:protocol];
    
    
    NSSet* result = [classUnderTest getClassesForProtocol:protocol];
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(1);
    EXP_expect([classUnderTest count]).to.equal(1);
}


-(void) test_setImplementations_validProtocolAndMultipleClasses_setsAndReturns {
    Protocol* protocol = @protocol(NSObject);
    
    
    [classUnderTest setImplementations:@[ [NSArray class] ] withProtocol:protocol];
    [classUnderTest setImplementations:@[ [NSArray class], [NSDictionary class] ] withProtocol:protocol];
    
    NSSet* result = [classUnderTest getClassesForProtocol:protocol];
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(2);
    EXP_expect([classUnderTest count]).to.equal(1);
}

-(void) test_getClassesForProtocol_nilProtocol_returnsEmptySet {
    NSSet* result = [classUnderTest getClassesForProtocol:nil];
    
    
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_getClassesForProtocol_validProtocolWithNoKey_returnsEmptySet {
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:@protocol(NSObject)];
    
    
    NSSet* result = [classUnderTest getClassesForProtocol:@protocol(NSCoding)];
    
    
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(0);
}

-(void) test_getClassesForProtocol_validWithKey_returnsEmptySet {
    Protocol* firstTestProtocol = @protocol(NSObject);
    Protocol* secondTestProtocol = @protocol(NSFastEnumeration);
    
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:firstTestProtocol];
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:secondTestProtocol];
    
    
    NSSet* result = [classUnderTest getClassesForProtocol:firstTestProtocol];
    
    
    EXP_expect(result).to.notTo.beNil;
    EXP_expect(result).to.beKindOf([NSSet class]);
    EXP_expect([result count]).to.equal(2);
    EXP_expect(result).to.contain([NSArray class]);
    EXP_expect(result).to.contain([NSDictionary class]);
}

-(void) test_unsetImplementationOfProtocol_nonExistingProtocol_doesNotEffectMap {
    Protocol* firstTestProtocol = @protocol(NSObject);
    Protocol* secondTestProtocol = @protocol(NSFastEnumeration);
    
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:firstTestProtocol];
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:secondTestProtocol];
    
    
    [classUnderTest unsetImplementationOfProtocol:@protocol(NSCoding)];
    
    
    EXP_expect([classUnderTest count]).to.equal(2);
}

-(void) test_unsetImplementationOfProtocol_existingProtocol_removesKey {
    Protocol* firstTestProtocol = @protocol(NSObject);
    Protocol* secondTestProtocol = @protocol(NSFastEnumeration);
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:firstTestProtocol];
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:secondTestProtocol];
    
    
    [classUnderTest unsetImplementationOfProtocol:firstTestProtocol];
    
    
    EXP_expect([classUnderTest count]).to.equal(1);
    EXP_expect([[classUnderTest getClassesForProtocol:secondTestProtocol] count]).to.equal(2);
}

-(void) test_unsetAllImplementations_works {
    Protocol* firstTestProtocol = @protocol(NSObject);
    Protocol* secondTestProtocol = @protocol(NSFastEnumeration);
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:firstTestProtocol];
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:secondTestProtocol];
    
    
    [classUnderTest unsetAllImplementations];
    
    
    NSSet* firstTestProtocolImplementations = [classUnderTest getClassesForProtocol:firstTestProtocol];
    NSSet* secondTestProtocolImplementations = [classUnderTest getClassesForProtocol:secondTestProtocol];
    EXP_expect([firstTestProtocolImplementations count]).to.equal(0);
    EXP_expect([secondTestProtocolImplementations count]).to.equal(0);
}

-(void) test_count_whenEmpty_returnsZero {
    NSUInteger counter = [classUnderTest count];
    
    EXP_expect(counter).to.equal(0);
}

-(void) test_count_hasOneKey_returns1 {
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:@protocol(NSObject)];
    
    
    NSUInteger counter = [classUnderTest count];
    
    
    EXP_expect(counter).to.equal(1);
}

-(void) test_count_hasTwoKeys_returns2 {
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:@protocol(NSObject)];
    [classUnderTest setImplementations:@[[NSArray class], [NSDictionary class]] withProtocol:@protocol(NSFastEnumeration)];
    
    
    NSUInteger counter = [classUnderTest count];
    
    
    EXP_expect(counter).to.equal(2);
}

@end
