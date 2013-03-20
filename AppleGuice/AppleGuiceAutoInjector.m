//Copyright 2013 Tomer Shiri appleguice@shiri.info
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

#import "AppleGuiceAutoInjector.h"

#import "AppleGuiceSettingsProviderProtocol.h"
#import "AppleGuiceInjectorProtocol.h"
#import "TheWrapper.h"
#import <objc/runtime.h>

@implementation AppleGuiceAutoInjector {
    id<AppleGuiceInjectorProtocol> _ioc_injector;
    id<AppleGuiceSettingsProviderProtocol> _ioc_settingsProvider;
    Class _targetClass;
    SEL _targetSelector;
}

@synthesize injector = _ioc_injector, settingsProvider = _ioc_settingsProvider;

-(id) init {
    self = [super init];
    if (!self) return self;
    _targetClass = [NSObject class];
    _targetSelector = @selector(init);
    return self;
}

-(void) startAutoInjector {
    [self _addInjectionWrapperToClass:_targetClass andSelector:_targetSelector];
}
-(void) stopAutoInjector {
    [TheWrapper removeWrapperFromClass:_targetClass andSelector:_targetSelector];
}

-(void) _addInjectionWrapperToClass:(Class) clazz andSelector:(SEL) selector {
    [TheWrapper addWrappertoClass:_targetClass andSelector:_targetSelector withPostRunBlock:^id(id<NSObject> zelf, id functionReturnValue, id firstArg, ...) {
        if (self.settingsProvider.methodInjectionPolicy == AppleGuiceMethodInjectionPolicyAutomatic) {
             [self.injector injectImplementationsToInstance:functionReturnValue];
        }
        return functionReturnValue;
    }];
}

-(void)dealloc {
    [self stopAutoInjector];
    [_ioc_injector release];
    [_ioc_settingsProvider release];
    [super dealloc];
}

@end
