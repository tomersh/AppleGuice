//
//  AppleGuiceSwiftClassesToTest.swift
//  AppleGuiceUnitTests
//
//  Created by Alex on 30/03/2018.
//  Copyright © 2018 Tomer Shiri. All rights reserved.
//

import Foundation

@objc protocol AppleGuiceUnitTestsAppleGuiceModule : class {
}

@objc protocol SwiftOptionalProtocolWithNoImplementation : AppleGuiceUnitTestsAppleGuiceModule, AppleGuiceOptional {
}


@objc protocol SwiftInjectedProtocol : AppleGuiceUnitTestsAppleGuiceModule {
}


class SwiftClassWithNoIvars : NSObject, AppleGuiceUnitTestsAppleGuiceModule {
}


class SwiftClassWithNonInjectableIvars : NSObject, AppleGuiceUnitTestsAppleGuiceModule {
    var nonInjectableIvar: NSObject?
}

class SwiftClassWithPrimitiveInjectableIvars : NSObject, AppleGuiceUnitTestsAppleGuiceModule {
    var _test_int: Int = 0
    var _test_float: Float = 0
    var _test_bool: Bool = false
}

class SwiftClassWithInjectableClass : NSObject, AppleGuiceUnitTestsAppleGuiceModule {
    var _test_injectableObject: SwiftClassWithNoIvars?
}

class SwiftClassWithInjectableProtocol: NSObject, AppleGuiceUnitTestsAppleGuiceModule {
    var _test_injectableProtocol: SwiftInjectedProtocol?
}

class SwiftClassWithInjectableArray : NSObject, AppleGuiceUnitTestsAppleGuiceModule {
    var _test_InjectedProtocol: NSArray?
}

class SwiftClassWithInjectableOptionalProtocol : NSObject, AppleGuiceUnitTestsAppleGuiceModule {
    var _test_optionalObject: SwiftOptionalProtocolWithNoImplementation?
}

