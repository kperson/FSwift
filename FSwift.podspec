Pod::Spec.new do |spec|
  spec.name         = 'FSwift'
  spec.version      = '1.4.5'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/kperson/FSwift'
  spec.authors      = 'Kelton Person'
  spec.summary      = 'functional programming library for Swift'
  spec.source       = { :git => 'https://github.com/kperson/FSwift.git', :tag => 'v1.4.5' }
  spec.source_files = 'FSwift/**/*.{swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
end
