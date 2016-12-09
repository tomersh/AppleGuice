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

#import "AppleGuiceProtocolToClassMapper.h"
#import "AppleGuiceSync.h"
#import <pthread.h>
#import <string>

@interface AppleGuiceProtocolToClassMapper ()

@property (nonatomic, retain) NSMutableDictionary<NSString*, NSMutableSet*>* mapper;

@end

@implementation AppleGuiceProtocolToClassMapper {
    pthread_mutex_t _mutex;
}

-(id)init {
    self = [super init];
    if (!self) return self;
    pthread_mutex_init(&_mutex, PTHREAD_MUTEX_NORMAL);
    self.mapper = [NSMutableDictionary dictionary];
    return self;
}

-(void)dealloc {
    pthread_mutex_unlock(&_mutex);
    pthread_mutex_destroy(&_mutex);
    [_mapper release];
    [super dealloc];
}

NSString* _storageKeyForProtocol(Protocol* protocol) {
    return NSStringFromProtocol(protocol);
}

-(NSMutableSet*) _getClassesForStorageKey:(NSString*) storageKey {
    return self.mapper[storageKey];
}

-(NSSet*) getClassesForProtocol:(Protocol*) protocol {
    if (!protocol) return [NSSet set];
    
    NSMutableSet* classes = nil;
    SYNC(classes = [self _getClassesForStorageKey:_storageKeyForProtocol(protocol)]);

    return [NSSet setWithSet:classes];
}

-(void) setImplementations:(NSArray<NSObject*>*)classes withProtocol:(Protocol*)protocol {
    if (!protocol || !classes) return;
    if ([classes count] == 0) return;
    
    NSString* storageKey = _storageKeyForProtocol(protocol);
    
    SYNC(
         NSMutableSet* boundClasses = [self _getClassesForStorageKey:storageKey];
         if (!boundClasses) {
             boundClasses = [NSMutableSet setWithArray:classes];
         }
         else {
             [boundClasses addObjectsFromArray:classes];
         }
    
         self.mapper[storageKey] = boundClasses;
    );
}

-(void) unsetImplementationOfProtocol:(Protocol*) protocol {
    SYNC([self.mapper removeObjectForKey:_storageKeyForProtocol(protocol)]);
}

-(void) unsetAllImplementations {
    SYNC([self.mapper removeAllObjects]);
}

-(NSUInteger) count {
    NSUInteger count = 0;
    SYNC(count = [self.mapper count]);
    return count;
}

@end
