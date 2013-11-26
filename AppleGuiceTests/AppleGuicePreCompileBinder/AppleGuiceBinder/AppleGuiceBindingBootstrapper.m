
// DO NOT EDIT. This file is machine-generated and constantly overwritten.
#import "AppleGuiceBindingBootstrapper.h"
#import "AppleGuice.h"
@implementation AppleGuiceBindingBootstrapper
@synthesize bindingService = _ioc_bindingService;

-(void) bootstrap {
[self.bindingService setImplementationsFromStrings:@[@"AnotherTestInjectableProtocolImplementor", @"TestInjectableClass", @"TestInjectableProtocolImplementor", @"TestInjectableSuperClass"] withProtocolAsString:@"AppleGuiceInjectable" withBindingType:appleGuiceBindingTypeUserBinding];
[self.bindingService setImplementationsFromStrings:@[@"AnotherTestInjectableProtocolImplementor", @"TestInjectableProtocolImplementor"] withProtocolAsString:@"TestInjectableSuperProtocol" withBindingType:appleGuiceBindingTypeUserBinding];
[self.bindingService setImplementationsFromStrings:@[@"AnotherTestInjectableProtocolImplementor", @"TestInjectableProtocolImplementor"] withProtocolAsString:@"TestInjectableProtocol" withBindingType:appleGuiceBindingTypeUserBinding];
}
@end
