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


#import "AppleGuiceOCMockMockProvider.h"

@implementation AppleGuiceOCMockMockProvider {
    Class _ocMock;
}

-(id) init {
    self = [super init];
    if (!self) return self;
    _ocMock = NSClassFromString(@"OCMockObject");
    return self;
}

-(id) mockForClass:(Class)aClass {
    if (![self _isServiceAvailable]) return nil;
    if (aClass == nil) return nil;
    return [_ocMock performSelector:@selector(mockForClass:) withObject:aClass];
}

-(id) mockForProtocol:(Protocol *)aProtocol {
    if (![self _isServiceAvailable]) return nil;
    if (aProtocol == nil) return nil;
    return [_ocMock performSelector:@selector(mockForProtocol:) withObject:aProtocol];
}

-(BOOL) _isServiceAvailable {
    return _ocMock != nil;
}

@end
