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


#import "AppleGuiceInvocationProxy.h"

@interface AppleGuiceInvocationProxy () {
    id (^_createInstanceBlock)(void);
    id _injectedObject;
}

@property (nonatomic, retain) id injectedObject;

@end

@implementation AppleGuiceInvocationProxy

@synthesize createInstanceBlock = _createInstanceBlock, injectedObject = _injectedObject;

-(void) _createObjectInstanceIfNeeded {
    if (_injectedObject) return;
    self.injectedObject = (self.createInstanceBlock ? self.createInstanceBlock() : nil);
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    [self _createObjectInstanceIfNeeded];
    return [self.injectedObject methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    [self _createObjectInstanceIfNeeded];
    [anInvocation setTarget:self.injectedObject];
    [anInvocation invoke];
    return;
}

- (NSString *)description {
    [self _createObjectInstanceIfNeeded];
    return [self.injectedObject description];
}
- (NSString *)debugDescription {
    if (self.injectedObject) return [self.injectedObject description];
    return NSStringFromClass([self class]);
}

-(void)dealloc {
    [_createInstanceBlock release];
    [_injectedObject release];
    [super dealloc];
}

@end
