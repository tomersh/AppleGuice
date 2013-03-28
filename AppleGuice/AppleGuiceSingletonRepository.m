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

#import "AppleGuiceSingletonRepository.h"

@interface AppleGuiceSingletonRepository () {
    NSMutableDictionary* _singletons;
}

@property (nonatomic, retain) NSMutableDictionary* singletons;

@end

@implementation AppleGuiceSingletonRepository

-(id) init {
    self = [super init];
    if (!self) return self;
    _singletons = [[NSMutableDictionary alloc] init];
    return self;
}

-(void) setSingletons:(NSMutableDictionary *) singletons {
    @synchronized(_singletons) {
        [_singletons release];
        _singletons = [singletons retain];
    }
}

-(NSMutableDictionary*) singletons {
    NSMutableDictionary* synchronizedSingletons;
    @synchronized(_singletons) {
        synchronizedSingletons = _singletons;
    }
    return synchronizedSingletons;
}

-(id) instanceForClass:(Class) clazz {
    id<NSCopying> storageKey = [self _storageKeyForClass:clazz];
    id instance = [self.singletons objectForKey:storageKey];
    return instance;
}

-(void) setInstance:(id) instance forClass:(Class) clazz {
    id<NSCopying> storageKey = [self _storageKeyForClass:clazz];
    [self.singletons setObject:instance forKey:storageKey];
}

-(BOOL) hasInstanceForClass:(Class) clazz {
    return [self instanceForClass:clazz] != nil;
}

-(id<NSCopying>) _storageKeyForClass:(Class) clazz {
    return [NSNumber numberWithUnsignedInt:[clazz hash]];
}

-(void) dealloc {
    [_singletons release];
    [super dealloc];
}

@end
