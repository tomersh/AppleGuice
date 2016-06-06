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

#import "AppleGuiceInjectableImplementationNotFoundException.h"

@implementation AppleGuiceInjectableImplementationNotFoundException

-(id)initWithIvarName:(NSString*) ivarName andProtocolName:(NSString*) protocolName {
    self = [super initWithName:@"AppleGuiceInjectableImplementationNotFoundException" reason:[NSString stringWithFormat:@"Unable to locate an implementation of protocol %@ for ivar %@. please set it up or enable auto implementation discovery.", protocolName, ivarName] userInfo:nil];
    return self;
}

-(id)initWithIvarName:(NSString*) ivarName andClassName:(NSString*) className {
    self = [super initWithName:@"AppleGuiceInjectableImplementationNotFoundException" reason:[NSString stringWithFormat:@"Unable to locate an implementation of class %@ for ivar %@. please set it up or enable auto implementation discovery.", className, ivarName] userInfo:nil];
    return self;
}

+(AppleGuiceInjectableImplementationNotFoundException*) exceptionWithIvarName:(NSString*) ivarName andProtocolName:(NSString*) protocolName {
    return [[[AppleGuiceInjectableImplementationNotFoundException alloc] initWithIvarName:ivarName andProtocolName:protocolName] autorelease];
}

+(AppleGuiceInjectableImplementationNotFoundException*) exceptionWithIvarName:(NSString*) ivarName andClassName:(NSString*) className {
    return [[[AppleGuiceInjectableImplementationNotFoundException alloc] initWithIvarName:ivarName andClassName:className] autorelease];
}

@end
