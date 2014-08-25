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
#include "AppleGuiceTypedDictionary.h"
#include <pthread.h>

@implementation AppleGuiceSingletonRepository {
    pthread_mutex_t _mutex;
    AppleGuice::AppleGuiceTypedDictionary<unsigned long, id> _singletons;
}

-(id)init {
    self = [super init];
    if (!self) return self;
    pthread_mutex_init(&_mutex, PTHREAD_MUTEX_NORMAL);
    return self;
}

-(void)dealloc {
    pthread_mutex_unlock(&_mutex);
    pthread_mutex_destroy(&_mutex);
    [super dealloc];
}

unsigned long _storageKeyForClass(Class clazz) {
    return (unsigned long)[clazz hash];
}

-(id) instanceForClass:(Class) clazz {
    id instance = nil;
    SYNC(instance = _singletons.objectForKey(_storageKeyForClass(clazz)));
    return instance;
}

-(void) setInstance:(id) instance forClass:(Class) clazz {
    SYNC(_singletons.setObject(_storageKeyForClass(clazz), instance));
}

-(void) clearRepository {
    SYNC(_singletons.removeAllObjects());
}

@end
