Pod::Spec.new do |spec|
  spec.name         = 'FSwift'
  spec.version      = '1.6.1'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/kperson/FSwift'
  spec.authors      = 'Kelton Person'
  spec.summary      = 'functional programming library for Swift'
  spec.source       = { :git => 'https://github.com/kperson/FSwift.git', :tag => 'multi-platform' }
  spec.source_files = 'FSwift/**/*.{swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.platforms = { :ios => '8.0', :osx => '10.7', :watchos => '2.0', :tvos => '9.0' }
end