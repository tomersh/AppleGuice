//
//  AppleGuiceTests.m
//  AppleGuiceTests
//
//  Created by Tomer Shiri on 3/19/13.
//  Copyright (c) 2013 Tomer Shiri. All rights reserved.
//
#import "AppleGuiceBindingServiceTests.h"
#import "AppleGuiceBindingService.h"

@implementation AppleGuiceBindingServiceTests {
    AppleGuiceBindingService* serviceUnderTest;
}

- (void)setUp
{
    [super setUp];
    serviceUnderTest = [[AppleGuiceBindingService alloc] init];
    
}

- (void)tests__setImplementation_withProtocol_withBindingType__nilImplementation__noBindingIsMade
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:nil withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).to.beNil();
}

- (void)tests__setImplementation_withProtocol_withBindingType__setUserBindToUserBindings__bindIsMadeToUserBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect([returnedProtocols objectAtIndex:0]).to.equal([NSObject class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
}

- (void)tests__setImplementation_withProtocol_withBindingType__setUserBindToCachedBindings__bindIsMadeToCachedBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect([returnedProtocols objectAtIndex:0]).to.equal([NSObject class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementations_withProtocol_withBindingType__nilImplementation__noBindingIsMade
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:nil withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).to.beNil();
}

- (void)tests__setImplementations_withProtocol_withBindingType__EmptyArrayImplementation__noBindingIsMade
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).to.beNil();
}

- (void)tests__setImplementations_withProtocol_withBindingType__setUserBindToUserBindings__bindIsMadeToUserBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[[NSObject class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect([returnedProtocols objectAtIndex:0]).to.equal([NSObject class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
}

- (void)tests__setImplementations_withProtocol_withBindingType__setUserBindWithMultipleClassesToUserBindings__bindIsMadeToUserBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[[NSObject class], [NSArray class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(2);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
}

- (void)tests__setImplementations_withProtocol_withBindingType__appendUserBindWithMultipleClassesToUserBindings__bindIsMadeToUserBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[[NSObject class], [NSDictionary class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementations:@[[NSArray class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(3);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
    EXP_expect(returnedProtocols).to.contain([NSDictionary class]);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
}

- (void)tests__setImplementations_withProtocol_withBindingType__setCachedBindToUserBindings__bindIsMadeToCached
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[[NSObject class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect([returnedProtocols objectAtIndex:0]).to.equal([NSObject class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementations_withProtocol_withBindingType__setCachedBindWithMultipleClassesToUserBindings__bindIsMadeToUserBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[[NSObject class], [NSArray class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(2);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementations_withProtocol_withBindingType__appendCachedBindWithMultipleClassesToUserBindings__bindIsMadeToUserBinding
{
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementations:@[[NSObject class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    [serviceUnderTest setImplementations:@[[NSArray class]] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(2);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__nilClassAndnilProtocol__NobindIsMade
{
    [serviceUnderTest setImplementationFromString:nil withProtocolAsString:nil withBindingType:appleGuiceBindingTypeUserBinding];
    
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__InvalidClassAndnilProtocol__NobindIsMade
{
    [serviceUnderTest setImplementationFromString:INVALID_CLASS_NAME withProtocolAsString:nil withBindingType:appleGuiceBindingTypeUserBinding];
    
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__ValidClassAndnilProtocol__NobindIsMade
{
    [serviceUnderTest setImplementationFromString:@"NSObject" withProtocolAsString:nil withBindingType:appleGuiceBindingTypeUserBinding];
    
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__nilClassAndInvalidProtocol__NobindIsMade
{
    [serviceUnderTest setImplementationFromString:nil withProtocolAsString:INVALID_PROTOCOL_NAME withBindingType:appleGuiceBindingTypeUserBinding];
    
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__nilClassAndValidProtocol__NobindIsMade
{
    [serviceUnderTest setImplementationFromString:nil withProtocolAsString:@"NSObject" withBindingType:appleGuiceBindingTypeUserBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).to.beNil();
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__invalidClassAndInvalidProtocol__NobindIsMade
{
    NSString* testProtocol = INVALID_PROTOCOL_NAME;
    [serviceUnderTest setImplementationFromString:INVALID_CLASS_NAME withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];

    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__validClassAndValidProtocol__bindIsMade
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationFromString:@"NSArray" withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
}

- (void)tests__setImplementationFromString_withProtocolAsString_withBindingType__validClassAndValidProtocol__bindIsMadeToCachedObjects
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationFromString:@"NSArray" withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationsFromStrings_withProtocolAsString_withBindingType__nilAsClasses__noBindIsMade
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationsFromStrings:nil withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).to.beNil();
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationsFromStrings_withProtocolAsString_withBindingType__emptyClassesArray__noBindIsMade
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationsFromStrings:@[] withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).to.beNil();
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationsFromStrings_withProtocolAsString_withBindingType__multipleValidClassesAndValidProtocol__bindIsMadeToCachedObjects
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationsFromStrings:@[@"NSArray", @"NSObject"] withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(2);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
}

- (void)tests__setImplementationsFromStrings_withProtocolAsString_withBindingType__multipleValidClassesAndValidProtocol__bindIsMadeToUserObjects
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationsFromStrings:@[@"NSArray", @"NSObject"] withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(2);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
}

- (void)tests__setImplementationsFromStrings_withProtocolAsString_withBindingType__validAndInvalidClassesAndValidProtocol__bindIsMadeOnlyToValidClasses
{
    NSString* testProtocol = @"NSObject";
    [serviceUnderTest setImplementationsFromStrings:@[@"NSArray", INVALID_CLASS_NAME] withProtocolAsString:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSObject)];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
}

-(void) test__unsetImplementationOfProtocol__nilProtocol_doesNotUnset {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    [serviceUnderTest unsetImplementationOfProtocol:nil];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
}

-(void) test__unsetImplementationOfProtocol__validProtocol_removesAllBinding {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSArray class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    [serviceUnderTest unsetImplementationOfProtocol:testProtocol];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
    EXP_expect(returnedProtocols).to.beNil();
}

-(void) test__unsetImplementationOfProtocol__removeOneBind_doesNotRemoveOtherBinds {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:@protocol(NSCoding) withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    
    [serviceUnderTest unsetImplementationOfProtocol:testProtocol];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:@protocol(NSCoding)];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
}

-(void) test__unsetAllImplementations_withType__userBinding__onlyUserBindingsAreRemoved {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSArray class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    [serviceUnderTest unsetAllImplementationsWithType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect([[self _getCachedObjects] count]).to.equal(1);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(0);
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
}

-(void) test__unsetAllImplementations_withType__cachedBinding__onlyCachedBindingsAreRemoved {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSArray class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    
    [serviceUnderTest unsetAllImplementationsWithType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect([[self _getCachedObjects] count]).to.equal(0);
    EXP_expect([[self _getUserBoundObjects] count]).to.equal(1);
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
}

-(void) test__getClassesForProtocol__nilProtocol__returnsNil {
    Protocol* testProtocol = @protocol(NSObject);
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect(returnedProtocols).to.beNil();
}

-(void) test__getClassesForProtocol__UserBoundProtocol__returnUserBoundProtocol {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
}

-(void) test__getClassesForProtocol__CachedBindingProtocol__returnCachedBindingProtocol {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSObject class]);
}

-(void) test__getClassesForProtocol__protocolThatBoundToUserAndCache__returnUserBoundProtocol {
    Protocol* testProtocol = @protocol(NSObject);
    [serviceUnderTest setImplementation:[NSArray class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeUserBinding];
    [serviceUnderTest setImplementation:[NSObject class] withProtocol:testProtocol withBindingType:appleGuiceBindingTypeCachedBinding];
    NSArray* returnedProtocols = [serviceUnderTest getClassesForProtocol:testProtocol];
    EXP_expect(returnedProtocols).notTo.beNil();
    EXP_expect([returnedProtocols count]).to.equal(1);
    EXP_expect(returnedProtocols).to.contain([NSArray class]);
}

-(NSDictionary*) _getCachedObjects {
    return (NSMutableDictionary*)[serviceUnderTest valueForKey:@"_cachedObjects"];
}

-(NSDictionary*) _getUserBoundObjects {
    return (NSMutableDictionary*)[serviceUnderTest valueForKey:@"_userBoundObjects"];
}

@end
