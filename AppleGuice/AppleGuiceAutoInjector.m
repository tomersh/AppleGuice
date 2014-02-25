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
#import "AppleGuiceInjectorProtocol.h"
#import <objc/runtime.h>

@implementation AppleGuiceAutoInjector

static IMP _originalInitMethodImp;
static id<AppleGuiceInjectorProtocol> _injector;
static BOOL _didStart;
static Class _targetClass;
static SEL _targetSelector;


static id _appleGuiceInjectionInitWrapper(id self, SEL _cmd) {
    id returnValue = nil;
    NSAutoreleasePool* autoReleasePool = [[NSAutoreleasePool alloc] init];
    returnValue = _originalInitMethodImp(self, _cmd);
    [_injector injectImplementationsToInstance:returnValue];
    [autoReleasePool drain];
    return returnValue;
}

+(void) setInjector:(id<AppleGuiceInjectorProtocol>) injector {
    [_injector release];
    _injector = [injector retain];
}

+(void)initialize {
    _targetClass = [NSObject class];
    _targetSelector = @selector(init);
    _didStart = NO;
}

+(void) startAutoInjector {
    if (_didStart) return;
    _didStart = YES;
    
    _originalInitMethodImp = class_replaceMethod(_targetClass, _targetSelector, (IMP)_appleGuiceInjectionInitWrapper, @encode(id));
}

+(void) stopAutoInjector {
    if (!_didStart) return;
    _didStart = NO;

    class_replaceMethod(_targetClass, _targetSelector, _originalInitMethodImp, @encode(id));
}

@end
