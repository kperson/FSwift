Pod::Spec.new do |spec|
  spec.swift_versions = ['5.0']
  spec.name         = 'FSwift'
  spec.version      = '3.0.0'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/kperson/FSwift'
  spec.authors      = 'Kelton Person'
  spec.summary      = 'functional programming library for Swift'
  spec.source       = { :git => 'https://github.com/kperson/FSwift.git', :tag => 'v3.0.0' }
  spec.source_files = 'FSwift/**/*.{swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '10.0'
  spec.watchos.deployment_target = '3.0'
end
