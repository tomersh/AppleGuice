//
//  BootstrapperTests.m
//  BootstrapperTests
//
//  Created by Tomer Shiri on 06/12/2017.
//  Copyright © 2017 Tomer Shiri. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Expecta.h>

@interface BootstrapperTests : XCTestCase

@end

EXPMatcherInterface(bindClassWithProtocol, (NSArray<NSString*>* classes, NSString* protocol));
#define bindClassWithProtocol bindClassWithProtocol
EXPMatcherImplementationBegin(bindClassWithProtocol, (NSArray<NSString*>* classes, NSString* protocol)) {
    
    NSMutableArray* classesAsEscapedStrings = [@[] mutableCopy];
    for (NSString* className in classes) {
        [classesAsEscapedStrings addObject:[NSString stringWithFormat:@"@\"%@\"", className]];
    }
    match(^BOOL {
        NSString* expected = [NSString stringWithFormat:@"[self.bindingService setImplementationsFromStrings:@[%@] withProtocolAsString:@\"%@\" withBindingType:appleGuiceBindingTypeUserBinding];", [classesAsEscapedStrings componentsJoinedByString:@", "], protocol];
        return [actual rangeOfString:expected].location != NSNotFound;
    });
    
    failureMessageForTo(^NSString * {
        return [NSString stringWithFormat:@"%@ is not binding %@", protocol, [classes componentsJoinedByString:@", "]];
    });
    
    failureMessageForNotTo(^NSString * {
        return [NSString stringWithFormat:@"%@ should not bind %@", protocol, [classes componentsJoinedByString:@", "]];
    });
}
EXPMatcherImplementationEnd

EXPMatcherInterface(ignoreClassAndProtocolPrefixes, (NSArray<NSString*>* prefixesToIgnore));
#define ignoreClassAndProtocolPrefixes ignoreClassAndProtocolPrefixes
EXPMatcherImplementationBegin(ignoreClassAndProtocolPrefixes, (NSArray<NSString*>* prefixesToIgnore)) {
    
    match(^BOOL {
        for (NSString *prefixToIgnore in prefixesToIgnore) {
            NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"self.bindingService setImplementationsFromStrings:@\\[.*?@\"%@.*?\"\\]", prefixToIgnore] options:0 error:nil];
            NSTextCheckingResult *match = [regExp firstMatchInString:actual options:0 range:NSMakeRange(0, ((NSString *)actual).length)];
            if (match) {
                return NO;
            }
        }
        return YES;
    });
    
    failureMessageForTo(^NSString * {
        return [NSString stringWithFormat:@"classes with prefixes %@ are not bindable", [prefixesToIgnore componentsJoinedByString:@", "]];
    });
    
    failureMessageForNotTo(^NSString * {
        return [NSString stringWithFormat:@"classes with prefixes should not bind %@", [prefixesToIgnore componentsJoinedByString:@", "]];
    });
}
EXPMatcherImplementationEnd

@implementation BootstrapperTests

static NSString* const executablePath = @"./Bootstrapper";
static NSString* const emptyString = @"";
static NSString* const noInputError = @"You need to pipe in some data!\n";
static NSString* const generatedHeader = @"// DO NOT EDIT. This file is machine-generated and constantly overwritten.\n#import \"AppleGuiceBindingBootstrapper.h\"\n#import \"AppleGuice.h\"\n@implementation AppleGuiceBindingBootstrapper\n@synthesize bindingService = _ioc_bindingService;\n\n-(void) bootstrap {\n";

struct CommandOutput {
    NSString* result;
    NSString* error;
};

-(struct CommandOutput) _runBootstrapper:(NSArray<NSString*>*) interfaceData {
    return [self _runBootstrapper:interfaceData ignorePrefixes:nil];
}

-(struct CommandOutput) _runBootstrapper:(NSArray<NSString*>*) interfaceData ignorePrefixes:(NSArray<NSString *> *)ignoredPrefixes {
    
    NSPipe* resultPipe = [NSPipe pipe];
    NSPipe* errorPipe = [NSPipe pipe];
    NSPipe* stdinPipe = [NSPipe pipe];
    
    NSTask* task = [[NSTask alloc] init];
    task.launchPath = executablePath;
    
    if (interfaceData) {
        task.standardInput = stdinPipe;
    }
    task.standardOutput = resultPipe;
    task.standardError = errorPipe;
    
    if (ignoredPrefixes.count > 0) {
        [task setArguments:@[@"./tmpAgBindings", @"*.framework*", @"Pods", [ignoredPrefixes componentsJoinedByString:@","]]];
    }
    
    [task launch];
    
    NSString* dataAsString = [[interfaceData componentsJoinedByString:@"\n"] stringByAppendingString:@"\n"];
    [stdinPipe.fileHandleForWriting writeData:[dataAsString dataUsingEncoding:NSUTF8StringEncoding]];
    [stdinPipe.fileHandleForWriting closeFile];
    
    [task waitUntilExit];
    
    NSData *resultData = [resultPipe.fileHandleForReading readDataToEndOfFile];
    [resultPipe.fileHandleForReading closeFile];
    
    NSData *errorData = [errorPipe.fileHandleForReading readDataToEndOfFile];
    [errorPipe.fileHandleForReading closeFile];
    
    NSString* result = [[NSString alloc] initWithData:resultData encoding: NSUTF8StringEncoding];
    NSString* error = [[NSString alloc] initWithData:errorData encoding: NSUTF8StringEncoding];
    
    struct CommandOutput commandOutput;
    commandOutput.result = result;
    commandOutput.error = error;
    
    return commandOutput;
}

- (void) test_noDataInput_resultsInError {
    struct CommandOutput res = [self _runBootstrapper:nil];
    
    expect(res.error).to.equal(noInputError);
    expect(res.result).to.equal(emptyString);
}

- (void)test_emptyBuildInfo_emptyMapFileGenerated {
    struct CommandOutput res = [self _runBootstrapper:@[]];

    [self _assertFileHeaderAndFooter:res];
}

- (void)test_injectableClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : X<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_injectableClassWithBraces_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : X<AppleGuiceInjectable> {"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_nonInjectableClassWithoutProtocol_doesNotAppearOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).notTo.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_nonInjectableClassWithProtocol_doesNotAppearOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : X<SomeProtocol>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).notTo.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_multipleInjectableClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
  @[@"@interface A : X<AppleGuiceInjectable>",
    @"@interface B : X<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"AppleGuiceInjectable");
}

- (void)test_injectableInheritedClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"@interface A : B",
                                  @"@interface B : C",
                                  @"@interface C : X<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
}

- (void)test_injectablePartialInheritedClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"@interface A : B",
                                  @"@interface B : C<AppleGuiceInjectable>",
                                  @"@interface C : X"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"AppleGuiceInjectable");
}

- (void)test_multipleinjectableInheritedClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"@interface A : B",
                                  @"@interface B : C<Y>",
                                  @"@interface C : X<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"Y");
}


- (void)test_multipleinjectableInheritedClassOnOneClassDef_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"@interface A : B",
                                  @"@interface B : C<X, Y,Z>",
                                  @"@interface C : X<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"X");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"Y");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"Z");
}


- (void)test_injectableClassFromProtocol_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : X<P>", @"@protocol P<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_injectableClassFromParentProtocol_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : X<P ,Q ,R>", @"@protocol P<Z>", @"@protocol Z<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"Z");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"P");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"Q");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"R");
}

- (void)test_injectableClassFromParentClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : B", @"@interface B : C<T>", @"@interface C : X<P, Q, R>",  @"@protocol P<Z>", @"@protocol Z<AppleGuiceInjectable>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"Z");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"P");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"T");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"Q");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"R");
}

- (void)test_classWithIgnoredPrefix_excludedFromMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : UIViewController<T, AppleGuiceInjectable>"] ignorePrefixes:@[@"UI"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"T");
    expect(res.result).to.ignoreClassAndProtocolPrefixes(@[@"UI"]);
}

- (void)test_classWithIgnoredStringNotPrefix_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : CFMUIViewController", @"@interface CFMUIViewController : UIViewController<AppleGuiceInjectable>"] ignorePrefixes:@[@"UI"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"CFMUIViewController"], @"AppleGuiceInjectable");
    expect(res.result).to.ignoreClassAndProtocolPrefixes(@[@"UI"]);
}

- (void)test_notInjectableClass_excludedFromMap {
    struct CommandOutput res = [self _runBootstrapper:@[]];
    
    [self _assertFileHeaderAndFooter:res];
}

- (void)test_injectableSwiftClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : X, AppleGuiceInjectable", @"class X : NSObject"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_injectableSwiftClassWithBraces_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : X, AppleGuiceInjectable {", @"class X : NSObject"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_injectableSwiftClassNoNSObjectBaseClass_doesNotAppearOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : AppleGuiceInjectable"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).notTo.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_nonInjectableSwiftClassWithoutProtocol_doesNotAppearOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).notTo.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_nonInjectableSwiftClassWithProtocol_doesNotAppearOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"@interface A : X<SomeProtocol>"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).notTo.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_multipleInjectableSwiftClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"class A : X, AppleGuiceInjectable",
                                  @"class B : X, AppleGuiceInjectable",
                                  @"class X : NSObject"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"AppleGuiceInjectable");
}

- (void)test_injectableInheritedSwiftClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"class A : B",
                                  @"class B : C",
                                  @"class C : X, AppleGuiceInjectable",
                                  @"class X"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
}

- (void)test_injectablePartialInheritedSwiftClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"class A : B",
                                  @"class B : C, AppleGuiceInjectable",
                                  @"class C : X"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"AppleGuiceInjectable");
}

- (void)test_multipleinjectableInheritedSwiftClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"class A : B",
                                  @"class B : C, Y",
                                  @"class C : X, AppleGuiceInjectable"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"Y");
}


- (void)test_multipleinjectableInheritedSwiftClassOnOneClassDef_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:
                                @[@"class A : B",
                                  @"class B : C, X, Y, Z",
                                  @"class C : X, AppleGuiceInjectable"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"X");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"Y");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"Z");
}

- (void)test_injectableSwiftClassFromProtocol_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : X, P", @"protocol P: AppleGuiceInjectable"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
}

- (void)test_injectableSwiftClassFromParentProtocol_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : X, P ,Q ,R", @"protocol P: Z", @"protocol Z: AppleGuiceInjectable"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"Z");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"P");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"Q");
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"R");
}

- (void)test_injectableSwiftClassFromParentClass_appearsOnMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : B", @"class B : C, T", @"class C : X, P, Q, R",  @"protocol P: Z", @"protocol Z: AppleGuiceInjectable"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"Z");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"P");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"AppleGuiceInjectable");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B"], @"T");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"Q");
    expect(res.result).to.bindClassWithProtocol(@[@"A", @"B", @"C"], @"R");
}

- (void)test_swiftClassWithIgnoredPrefix_excludedFromMap {
    struct CommandOutput res = [self _runBootstrapper:@[@"class A : UIViewController, T, AppleGuiceInjectable"] ignorePrefixes:@[@"UI"]];
    
    [self _assertFileHeaderAndFooter:res];
    expect(res.result).to.bindClassWithProtocol(@[@"A"], @"T");
    expect(res.result).to.ignoreClassAndProtocolPrefixes(@[@"UI"]);
}

-(void) _assertFileHeaderAndFooter:(struct CommandOutput) res {
    expect(res.result).to.beginWith(generatedHeader);
    expect(res.result).to.endWith(@"}\n@end\n\n");
    expect(res.error).to.equal(emptyString);
}

@end
