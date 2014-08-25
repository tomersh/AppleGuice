AppleGuice
==========

Effortless dependency injection framework for Objective-C

[![Build Status](https://travis-ci.org/tomersh/AppleGuice.png?branch=master)](https://travis-ci.org/tomersh/AppleGuice)
[![Coverage Status](https://coveralls.io/repos/tomersh/AppleGuice/badge.png?branch=master)](https://coveralls.io/r/tomersh/AppleGuice?branch=master)

## Who is using it? ##

[![Flashcards+](http://i61.tinypic.com/30ib6hi.jpg) FlashCards+](https://itunes.apple.com/app/id408490162) 
[![CheggApp](http://oi59.tinypic.com/517m9c.jpg) Chegg – Textbooks, eTextbooks & Study Tools](https://itunes.apple.com/app/id385758163)

Are you using AppleGuice and your app is not on the list? [Drop me a line](mailto:github@shiri.info).

## What AppleGuice does for you? ##

AppleGuice helps you write clean, reuseable and testable code by allowing you to easily inject your services to any class.
Other dependency injection frameworks require binding, xml editing or initializing your classes with a special method.
With AppleGuice all you have to do is declare the injected type and thats it. As a bonus, you will still be able to initialize classes with `[[MyClass alloc] init]` so it is even easier to integrate it with your existing code base.

## Show Me ##

### Inject your first injectable instance with 3 simple steps: ###

#### Start AppleGuice ####
```objectivec

//AppDelegate.m

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//Some code

[AppleGuice startService];

//More Code
}
```
#### Create your injectable service ####
Mark your injectable service with the protocol `AppleGuiceInjectable` so AppleGuice will find it.
```objectivec

@protocol MyServiceProtocol <AppleGuiceInjectable>

-(void) doStuff;

@end

@interface MyService : NSObject<MyServiceProtocol>
@end

@implementation MyService
...
@end
```

#### Enjoy automatic injection while coding ####
Create an ivar prefixed with the ioc prefix (the default is `_ioc_`).
AppleGuice will automatically inject the proper implementation when calling the init method.
```objectivec
//MyClass.h
@interface MyClass : NSObject

@property (nonatomic, strong) id<MyServiceProtocol> ioc_myService;

@end

//MyClass.m
@implementation MyClass

//Now, you can use _ioc_myService anywhere. Even in the init function!

-(id) init {
  self = [super init];
  [self.ioc_myService doStuff];
  return self;
}
@end
```
AppleGuice initialized `_ioc_myService`  without any manual binding!

#### Stub with ease while testing ####
```objectivec
#import <AppleGuice/AppleGuice.h>

@implementation MyClassTests {
    MyClass* classUnderTest;
}

-(void)setUp
{
    [super setUp];
    [AppleGuice startService];
    [AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyCreateMocks];
    classUnderTest = [[MyClass alloc] init];
}

-(void) test_foo_returnsValue {
  //the injectable ivar is initialized with a mock. You can stub methods on it as you normally do with OCMock.
  [[[classUnderTest.ioc_myService expect] andReturn:@"someString"] doStuff:OCMOCK_ANY];
  
  [classUnderTest foo];
  
  [classUnderTest.ioc_myService verify];
}
```
*When testing, AppleGuice works best with [OCMock](http://ocmock.org/).

## Inject In every flavour ##
Injecting a service is done by declering an ivar in a class. You can add it in the interface, implementation, as a property or even inside a private category. AppleGuice will find it.
Injection comes in three flavours:
```objectivec
@interface MyClass () {
    MyService* _ioc_MyService; //will create an instance of MyService.
    id<MyServiceProtocol> _ioc_MyService //will create an instance of the first class conforming to MyServiceProtocol.
    NSArray* _ioc_MyProtocol //will return an array containing instances of all classes conforming to MyProtocol
}
```

## More features ##

### Singletons in a snap ###
Instead of messing your code with shared instance declerations or macros, you can just add `AppleGuiceSingleton` to the implemented protocols list and AppleGuice will always return the same instance.
```objectivec
@protocol MyServiceProtocol <AppleGuiceInjectable, AppleGuiceSingleton>
@end
```

### Circular dependency support ###
AppleGuice can handle circular depenency between injected classes as long as the dependent classes conforms to `AppleGuiceSingleton`.

### LazyLoad objects ###
You can configure AppleGuice to inject a proxy object instead of the real service. Once the service is needed (A method in the service is called) the proxy will be replaced with the real object.
```objectivec
//add in your AppDelegate
[AppleGuice setInstanceCreationPolicy:AppleGuiceInstanceCreationPolicyLazyLoad];
```

## Ready to start? ##
Check out the quick [installation guide](https://github.com/tomersh/AppleGuice/wiki/AppleGuice-Installation-Guide).

Documentation can be found [here](http://cocoadocs.org/docsets/AppleGuice).
[![githalytics.com alpha](https://cruel-carlota.pagodabox.com/e73586a87135304cb47ff18e519b75f6 "githalytics.com")](http://githalytics.com/tomersh/AppleGuice)
