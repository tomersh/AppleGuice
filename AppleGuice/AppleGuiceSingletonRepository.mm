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
#import <pthread.h>

#if __cplusplus >= 201103L
#import <unordered_map>
#else
#import <tr1/unordered_map>
using namespace std::tr1;
#endif

using namespace std;

#define SYNC(...) pthread_mutex_lock(&_mutex); __VA_ARGS__; pthread_mutex_unlock(&_mutex);

@interface AppleGuiceSingletonRepository () {
    pthread_mutex_t _mutex;
    unordered_map<unsigned long, id > _singletons;
}

@end

@implementation AppleGuiceSingletonRepository

-(id) init {
    self = [super init];
    if (!self) return self;
    _singletons = unordered_map<unsigned long, id >();
    pthread_mutex_init(&_mutex, PTHREAD_MUTEX_NORMAL);
    return self;
}

unsigned long _storageKeyForClass(Class clazz) {
    return (unsigned long)[clazz hash];
}

-(id) instanceForClass:(Class) clazz {
    if (![self hasInstanceForClass:clazz]) {
        return nil;
    }
    
    NSUInteger storageKey = _storageKeyForClass(clazz);
    
    id instance = nil;
    SYNC(instance = _singletons[storageKey]);
    return instance;
}

-(void) setInstance:(id) instance forClass:(Class) clazz {
    unsigned long storageKey = _storageKeyForClass(clazz);
    SYNC(_singletons[storageKey] = instance);
}

-(BOOL) hasInstanceForClass:(Class) clazz {
    NSUInteger storageKey = _storageKeyForClass(clazz);
    return _singletons.find(storageKey) != _singletons.end();
}

-(void) clearRepository {
    SYNC(_singletons.clear());
}

-(void) dealloc {
    pthread_mutex_unlock(&_mutex);
    pthread_mutex_destroy(&_mutex);
    [super dealloc];
}

@end
