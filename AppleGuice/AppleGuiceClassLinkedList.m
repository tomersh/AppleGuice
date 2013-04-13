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


#import "AppleGuiceClassLinkedList.h"

typedef struct classLink {
    Class clazz;
    struct classLink* next;
} classLinkedList;

classLinkedList* createLink(Class clazz) {
    classLinkedList* link = (classLinkedList*)malloc(sizeof(classLinkedList));
    link->clazz = clazz;
    link->next = NULL;
    return link;
}

classLinkedList* addLink(classLinkedList* list, classLinkedList* newLink) {
    if (newLink == NULL) return list;
    if (list == NULL) return newLink;
    list->next = newLink;
    return newLink;
}

void disposeList(classLinkedList* list) {
    if (list == NULL) return;

    classLinkedList* nextLink = list->next;
    free(list);
    list = NULL;

    disposeList(nextLink);
}

@implementation AppleGuiceClassLinkedList {
    classLinkedList* _listAnchor;
    classLinkedList* _listHead;
}

+(AppleGuiceClassLinkedList*) list {
    return [[[AppleGuiceClassLinkedList alloc] init] autorelease];
}

-(id) init {
    self = [super init];
    if (!self) return self;

    _listHead = NULL;
    _listAnchor = NULL;

    return self;
}

-(void) addClass:(Class) clazz {
    classLinkedList* newLink = createLink(clazz);
    if (_listAnchor == NULL) {
        _listAnchor = newLink;
    }
    _listHead = addLink(_listHead, newLink);
}

-(NSArray*) toArray {
    NSMutableArray* linkedListAsArray = [NSMutableArray array];
    for (classLinkedList* link = _listAnchor; link != NULL; link = link->next) {
        [linkedListAsArray addObject:link->clazz];
    }
    return [NSArray arrayWithArray:linkedListAsArray];
}

-(void) clearList {
    disposeList(_listAnchor);
    _listAnchor = NULL;
    _listHead = NULL;
}

- (void)dealloc {
    [self clearList];
    [super dealloc];
}

@end
