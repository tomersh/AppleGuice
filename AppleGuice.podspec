Pod::Spec.new do |s|
  s.name         = 'AppleGuice'
  s.version      = '1.2.2'
  s.summary      = 'Effortless dependency injection framework for Objective-C'
  s.description  = <<-DESC
                   AppleGuice helps you write clean, reuseable and testable code by allowing you to easily inject your services to any class. Other dependency injection frameworks require binding, xml editing or initializing your classes with a special method. With AppleGuice all you have to do is declare the injected type and thats it. As a bonus, you will still be able to initialize classes with [[MyClass alloc] init] so it is even easier to integrate it with your existing code base.
                   DESC
  s.homepage     = 'http://github.com/tomersh/AppleGuice'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.author       = { 'Tomer Shiri' => 'appleguice@shiri.info' }
  s.platform = :ios, '5.0'
  s.source       = { :git => 'https://github.com/tomersh/AppleGuice.git', :tag => 'v1.2.2' }
  s.source_files  = 'AppleGuice/**/*.{h,m,mm}'
  s.preserve_paths = 'Bootstrapper/*', 'AppleGuicePreCompileBinder/*', 'AppleGuice/AppleGuice-Prefix.pch'
  s.prefix_header_file = 'AppleGuice/AppleGuice-Prefix.pch'
  s.requires_arc = false
  s.libraries = 'c++'
end
