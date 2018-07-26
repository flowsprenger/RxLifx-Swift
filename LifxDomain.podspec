Pod::Spec.new do |s|
  s.name         = "LifxDomain"
  s.version      = "0.0.1"

  s.summary      = "LIFX Message definition and (de)serialization code for integration with your own code. Has no external dependencies."
  s.description  = <<-DESC
                   Part of the RxLifx-Swift set of frameworks
                   DESC

  s.homepage     = "https://github.com/flowsprenger/RxLifx-Swift"
  s.license      = 'MIT'
  s.author       = 'Florian Sprenger'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.2'
  s.macos.deployment_target = '10.11'

  s.source       = { :git => "https://github.com/flowsprenger/RxLifx-Swift.git" }

  s.source_files = 'LifxDomain/LifxDomain/*.{h,swift}'
end
