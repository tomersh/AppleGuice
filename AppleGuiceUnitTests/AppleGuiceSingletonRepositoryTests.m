//
//  AppleGuiceSingletonRepositoryTests.m
//  AppleGuice
//
//  Created by Tomer Shiri on 3/17/14.
//  Copyright (c) 2014 Tomer Shiri. All rights reserved.
//

#import "AppleGuiceSingletonRepositoryTests.h"
#import "AppleGuiceSingletonRepository.h"

@interface AppleGuiceSingletonRepositoryTestTestClass : NSObject
@end
@implementation AppleGuiceSingletonRepositoryTestTestClass
@end

@interface AppleGuiceSingletonRepositoryTestTestClass2 : AppleGuiceSingletonRepositoryTestTestClass
@end
@implementation AppleGuiceSingletonRepositoryTestTestClass2
@end

@implementation AppleGuiceSingletonRepositoryTests {
    AppleGuiceSingletonRepository* serviceUnderTest;
}

-(void)setUp {
    [super setUp];
    serviceUnderTest = [[AppleGuiceSingletonRepository alloc] init];
}

-(void)tearDown {
    [serviceUnderTest release];
    serviceUnderTest = nil;
    [super tearDown];
}

-(void) test_instanceForClass_nilClass_returnsNil {
    id instance = [serviceUnderTest instanceForClass:NSClassFromString(@"+clazz")];
    
    EXP_expect(instance).to.beNil;
}

-(void) test_instanceForClass_validClassWithSingleton_returnsInstance {
    Class clazz = [AppleGuiceSingletonRepositoryTestTestClass class];
    id instance = [[[clazz alloc] init] autorelease];
    [serviceUnderTest setInstance:instance forClass:clazz];
    
    id fetchedInstance = [serviceUnderTest instanceForClass:clazz];
    
    unsigned long retainCount = [fetchedInstance retainCount];
    
    EXP_expect(fetchedInstance).to.equal(instance);
    EXP_expect(retainCount).to.equal(2);
}

-(void) test_instanceForClass_validClassWithoutSingleton_returnsNil {
    Class clazz = [AppleGuiceSingletonRepositoryTestTestClass class];
    
    id fetchedInstance = [serviceUnderTest instanceForClass:clazz];
    
    EXP_expect(fetchedInstance).to.beNil;
}

-(void) test_reSetClassWithNewInstance_returnsNewInstance {
    Class clazz = [AppleGuiceSingletonRepositoryTestTestClass class];
    [serviceUnderTest setInstance:[[[clazz alloc] init] autorelease] forClass:clazz];
    id instance = [[[AppleGuiceSingletonRepositoryTestTestClass alloc] init] autorelease];
    [serviceUnderTest setInstance:instance forClass:clazz];
    
    id fetchedInstance = [serviceUnderTest instanceForClass:clazz];
    unsigned long retainCount = [fetchedInstance retainCount];
    
    EXP_expect(fetchedInstance).to.equal(instance);
    EXP_expect(retainCount).to.equal(2);
}

-(void) test_reSetInstanceOfSameClass_returnsInstance {
    Class clazz = [AppleGuiceSingletonRepositoryTestTestClass class];
    id instance = [[[clazz alloc] init] autorelease];
    [serviceUnderTest setInstance:instance forClass:clazz];
    [serviceUnderTest setInstance:instance forClass:clazz];
    
    id fetchedInstance = [serviceUnderTest instanceForClass:clazz];
    unsigned long retainCount = [fetchedInstance retainCount];
    
    EXP_expect(fetchedInstance).to.equal(instance);
    EXP_expect(retainCount).to.equal(2);
}

-(void) test_instancesOftwoTypes_returnsdifferentInstances {
    Class clazz1 = [AppleGuiceSingletonRepositoryTestTestClass class];
    Class clazz2 = [AppleGuiceSingletonRepositoryTestTestClass2 class];
    id instance1 = [[[clazz1 alloc] init] autorelease];
    id instance2 = [[[clazz2 alloc] init] autorelease];
    [serviceUnderTest setInstance:instance1 forClass:clazz1];
    [serviceUnderTest setInstance:instance2 forClass:clazz2];
    
    id fetchedInstance1 = [serviceUnderTest instanceForClass:clazz1];
    id fetchedInstance2 = [serviceUnderTest instanceForClass:clazz2];
    
    unsigned long retainCount1 = [fetchedInstance1 retainCount];
    unsigned long retainCount2 = [fetchedInstance2 retainCount];
    
    EXP_expect(fetchedInstance1).to.equal(instance1);
    EXP_expect(fetchedInstance2).to.equal(instance2);
    EXP_expect(fetchedInstance1).toNot.equal(fetchedInstance2);
    EXP_expect(retainCount1).to.equal(2);
    EXP_expect(retainCount2).to.equal(2);
}

-(void) test_clearRepository_clearsInstances {
    Class clazz1 = [AppleGuiceSingletonRepositoryTestTestClass class];
    Class clazz2 = [AppleGuiceSingletonRepositoryTestTestClass2 class];
    id instance1 = [[[clazz1 alloc] init] autorelease];
    id instance2 = [[[clazz2 alloc] init] autorelease];
    [serviceUnderTest setInstance:instance1 forClass:clazz1];
    [serviceUnderTest setInstance:instance2 forClass:clazz2];
    
    [serviceUnderTest clearRepository];
    
    id fetchedInstance1 = [serviceUnderTest instanceForClass:clazz1];
    id fetchedInstance2 = [serviceUnderTest instanceForClass:clazz2];
    
    unsigned long retainCount1 = [instance1 retainCount];
    unsigned long retainCount2 = [instance2 retainCount];
    
    EXP_expect(fetchedInstance1).to.beNil;
    EXP_expect(fetchedInstance2).to.beNil;
    EXP_expect(retainCount1).to.equal(1);
    EXP_expect(retainCount2).to.equal(1);
}

-(void) test_clearRepository_insertInstanceAfterClear_works {
    [serviceUnderTest clearRepository];
    [self test_instanceForClass_validClassWithSingleton_returnsInstance];
}

@end
