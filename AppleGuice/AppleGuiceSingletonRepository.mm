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
    id instance = nil;
    unsigned long storageKey = _storageKeyForClass(clazz);

    SYNC(
    if ([self _hasInstanceForStorageKey:storageKey]) {
        instance = _singletons[storageKey];
    }
    );
    return instance;
}

-(void) setInstance:(id) instance {
    if (!instance) return;
    
    unsigned long storageKey = _storageKeyForClass([instance class]);
    SYNC(
    if ([self _hasInstanceForStorageKey:storageKey]) {
        id oldInstance = _singletons[storageKey];
        [oldInstance release];
        oldInstance = nil;
    }
    _singletons[storageKey] = [instance retain];
    );
}

-(BOOL) _hasInstanceForStorageKey:(unsigned long) storageKey {
    return _singletons.find(storageKey) != _singletons.end();
}

-(void) clearRepository {
    SYNC(
    for (auto it = _singletons.begin(); it != _singletons.end();) {
        id instance = it->second;
        [instance release];
        instance = nil;
        it = _singletons.erase(it);
    }
    );
}

-(void) dealloc {
    [self clearRepository];
    pthread_mutex_unlock(&_mutex);
    pthread_mutex_destroy(&_mutex);
    [super dealloc];
}

@end
