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

#import "AppleGuiceProtocolLocator.h"
#import "AppleGuiceBindingServiceProtocol.h"
#import "AppleGuiceInjectable.h"
#import "AppleGuiceClassLinkedList.h"
#import <objc/runtime.h>


@implementation AppleGuiceProtocolLocator {

    unsigned int _allClassCount;
    Class* _allClassesMemoization;
    NSArray* _filteredClasses;
    id<AppleGuiceBindingServiceProtocol> _ioc_bindingService;
}

@synthesize bindingService = _ioc_bindingService;


-(id) init {
    self = [super init];
    if (!self) return self;
    
    _allClassesMemoization = NULL;
    _allClassCount = 0;
    
    return self;
}

-(void) bootstrapAutomaticImplementationDiscovery {
    if (_allClassesMemoization) return;

    _allClassCount = objc_getClassList(NULL, 0);
    
    _allClassesMemoization = malloc(sizeof(Class) * _allClassCount);
    _allClassCount = objc_getClassList(_allClassesMemoization, _allClassCount);
}


-(void) setFilterProtocol:(Protocol*) filterProtocol {

    [_filteredClasses release];
    _filteredClasses = nil;
    [self.bindingService unsetAllImplementationsWithType:appleGuiceBindingTypeCachedBinding];

    if (!filterProtocol) return;

    _filteredClasses = [[self _filterAllClassesWithProtocol:filterProtocol] retain];
}

-(NSArray *) getAllClassesByProtocolType:(Protocol*) protocol {
    
    NSArray* allMatchingClasses = [self.bindingService getClassesForProtocol:protocol];
 
    if (allMatchingClasses) {
        return allMatchingClasses;
    }
    
    allMatchingClasses = [self _filterAllFilteredClassesProtocol:protocol];
    
    if (allMatchingClasses) {
        [self.bindingService setImplementations:allMatchingClasses withProtocol:protocol withBindingType:appleGuiceBindingTypeCachedBinding];
        return allMatchingClasses;
    }
    
    allMatchingClasses = [self _filterAllClassesWithProtocol:protocol];
    
    if (allMatchingClasses) {
        [self.bindingService setImplementations:allMatchingClasses withProtocol:protocol withBindingType:appleGuiceBindingTypeCachedBinding];
        return allMatchingClasses;
    }
    return allMatchingClasses;
}

-(NSArray*) _filterAllClassesWithProtocol:(Protocol*) filterProtocol {
    NSMutableSet* filteredClasses = [NSMutableSet set];
    for (int i = 0; i < _allClassCount; i++) {
        Class clazz = _allClassesMemoization[i];
        AppleGuiceClassLinkedList* classLinkedList = [AppleGuiceClassLinkedList list];
        while (clazz) {
            [classLinkedList addClass:clazz];
            if (class_conformsToProtocol(clazz, filterProtocol)) {
                NSArray* conformingClassesList = [classLinkedList toArray];
                [filteredClasses addObjectsFromArray:conformingClassesList];
                break;
            }
            clazz = class_getSuperclass(clazz);
        }
    }
    
    if ([filteredClasses count] == 0) return nil;
    
    return [NSArray arrayWithArray:[filteredClasses allObjects]];
}

-(NSArray*) _filterAllFilteredClassesProtocol:(Protocol*) protocol {
    return [self _filterClassesArray:_filteredClasses withProtocol:protocol];
}

-(NSArray*) _filterClassesArray:(NSArray*) classesArray withProtocol:(Protocol*) protocol {
    if (!classesArray) return nil;
    NSMutableArray* filteredClasses = [NSMutableArray arrayWithCapacity:[classesArray count]];
    for (Class clazz in classesArray) {
        if ([clazz conformsToProtocol:protocol]) {
            [filteredClasses addObject:clazz];
        }
    }
    
    if ([filteredClasses count] == 0) return nil;
    
    return [NSArray arrayWithArray:filteredClasses];
}


-(void) dealloc {
    [_ioc_bindingService release];
    [_filteredClasses release];
    free(_allClassesMemoization);
    [super dealloc];
}

@end
