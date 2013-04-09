AppleGuice
==========

A powerful convention over configuration driven dependency injection framework for Objective-C


## What AppleGuice does for you? ##

AppleGuice lets you write clean, reuseable and testable code by allowing you to easily inject your services to any class.
Other dependency injection frameworks require binding, xml editing or initializing your classes with a special method.
With AppleGuice all you have to do is declare the injected type and thats it. As a bonus, you will still be able to initialize classes with `[[MyClass alloc] init]` so it is even easier to integrate it with your existing code base.

## Show Me ##

Inject your first injectable instance with 3 simple steps:

Start AppleGuice
```objectivec

//AppDelegate.m

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//Some code

[AppleGuice startService];

//More Code
}
```
Create your injectable service
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

Inject
```objectivec
@implementation MyClass {
  id<MyServiceProtocol> _ioc_myService;
}

//use _ioc_myService anywhere. Even in the init function!

-(id) init {
  self = [super init];
  [_ioc_myService doStuff];
  return self;
}
@end
```

## Inject In every flavour ##
Injecting a service is done by declering an ivar in a class. You can add it in the interface, implementation, as a property or even inside a private category. AppleGuice will find it.
You can injection comes in three flavours:
```objectivec
@interface MyClass () {
    MyService* _ioc_MyService; //will create an instance of MyService.
    id<MyServiceProtocol> _ioc_MyService //will create an instance of the first class conforming to MyProtocol.
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
