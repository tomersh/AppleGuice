Pod::Spec.new do |s|
  s.name         = 'AppleGuice'
  s.version      = '1.3.0'
  s.summary      = 'Effortless dependency injection framework for Objective-C'
  s.description  = <<-DESC
                   AppleGuice helps you write clean, reuseable and testable code by allowing you to easily inject your services to any class. Other dependency injection frameworks require binding, xml editing or initializing your classes with a special method. With AppleGuice all you have to do is declare the injected type and thats it. As a bonus, you will still be able to initialize classes with [[MyClass alloc] init] so it is even easier to integrate it with your existing code base.
                   DESC
  s.homepage     = 'http://github.com/tomersh/AppleGuice'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { 'Tomer Shiri' => 'appleguice@shiri.info' }
  
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.7'
  s.tvos.deployment_target = '9.0'

  s.source       = { :git => 'https://github.com/tomersh/AppleGuice.git', :tag => 'v' + s.version.to_s }
  s.source_files  = 'AppleGuice/**/*.{h,m,mm}'
  s.private_header_files = 'AppleGuice/InjectionContainer/IvarAccess.h'
  s.preserve_paths = 'Bootstrapper/*', 'AppleGuicePreCompileBinder/*'
  s.exclude_files = 'AppleGuice/AppleGuiceBindingBootstrapper.m'

  s.requires_arc = false
  s.libraries = 'c++'
  s.prepare_command = 'make -C ./Bootstrapper'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }
  s.dependency 'SwiftIvarAccess'
end