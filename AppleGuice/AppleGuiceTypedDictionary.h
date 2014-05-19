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

#ifndef __AppleGuiceTypedDictionary_H
#define __AppleGuiceTypedDictionary_H

#include <objc/objc.h>
#include <objc/message.h>

#define retain(__obj) objc_msgSend(__obj, sel_getUid("retain"))
#define release(__obj) objc_msgSend(__obj, sel_getUid("release"))

namespace AppleGuice {

template < class K, class V >
class AppleGuiceTypedDictionary {

private:
    unordered_map<K,V> _dictionary;
    
public:
    
    V objectForKey(K key) {
        V object = NULL;
        if (hasObjectForKey(key)) {
            object = _dictionary[key];
        }
        return object;
    }
    
    bool hasObjectForKey(K key) {
        return _dictionary.find(key) != _dictionary.end();
    }
    
    void setObject(K key, V object) {
        if (object == NULL) return;
        
        if (hasObjectForKey(key)) {
            V oldObject = _dictionary[key];
            release(oldObject);
        }
        retain(object);
        _dictionary[key] = object;
    }
    
    V removeObject(K key) {
        V object = NULL;
        if (hasObjectForKey(key)) {
            object = _dictionary[key];
            release(object);
            _dictionary.erase(key);
        }
        return object;
    }

    void removeAllObjects() {
        for (auto it = _dictionary.begin(); it != _dictionary.end();) {
            release(it->second);
            it = _dictionary.erase(it);
        }
    }
    
    unsigned long count() {
        return _dictionary.size();
    }
};

}

#endif
