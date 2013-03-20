//
// Created by tomer on 3/14/13.
//
// To change the template use AppCode | Preferences | File Templates.
//

#ifndef __APPLE_GUICE_MACROS___
#define __APPLE_GUICE_MACROS___

#define AG_IVAR(__clazz, __name) __clazz* _ioc_##__name;
#define AG_ARRAY_OF_PROTOCOL(__protocol) AG_IVAR(NSArray, __protocol);

#endif