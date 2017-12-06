
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
#import "AppleGuiceBindingBootstrapper.h"
#import "AppleGuice.h"
@implementation AppleGuiceBindingBootstrapper
@synthesize bindingService = _ioc_bindingService;

-(void) bootstrap {
[self.bindingService setImplementationsFromStrings:@[@"TestInjectableSingletonClass"] withProtocolAsString:@"AppleGuiceSingleton" withBindingType:appleGuiceBindingTypeUserBinding];
[self.bindingService setImplementationsFromStrings:@[@"TestInjectableSingletonClass"] withProtocolAsString:@"TestProtocolForSingletonClasses" withBindingType:appleGuiceBindingTypeUserBinding];
[self.bindingService setImplementationsFromStrings:@[@"AnotherTestInjectableProtocolImplementor", @"TestInjectableProtocolImplementor"] withProtocolAsString:@"TestInjectableSuperProtocol" withBindingType:appleGuiceBindingTypeUserBinding];
[self.bindingService setImplementationsFromStrings:@[@"AnotherTestInjectableProtocolImplementor", @"TestInjectableProtocolImplementor"] withProtocolAsString:@"TestInjectableProtocol" withBindingType:appleGuiceBindingTypeUserBinding];
[self.bindingService setImplementationsFromStrings:@[@"AnotherTestInjectableProtocolImplementor", @"AppleGuiceSanityTestClass", @"AppleGuiceSanityTestSuperClass", @"TestInjectableClass", @"TestInjectableProtocolImplementor", @"TestInjectableSingletonClass", @"TestInjectableSuperClass"] withProtocolAsString:@"AppleGuiceInjectable" withBindingType:appleGuiceBindingTypeUserBinding];
}
@end
