Pod::Spec.new do |spec|
  spec.name         = 'FSwift'
  spec.version      = '2.0.1'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/kperson/FSwift'
  spec.authors      = 'Kelton Person'
  spec.summary      = 'functional programming library for Swift'
  spec.source       = { :git => 'https://github.com/kperson/FSwift.git', :tag => 'v2.0.1' }
  spec.source_files = 'FSwift/**/*.{swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
end