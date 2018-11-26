Pod::Spec.new do |s|
  s.name         = "RxLifxApi"
  s.version      = "0.0.1"

  s.summary      = "Simple Api demonstrating usage RxLifx and LifxDomain"
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

  s.dependency 'RxSwift', '4.2.0'
  s.dependency 'RxLifx'
  s.dependency 'LifxDomain'

  s.source_files = 'RxLifxApi/RxLifxApi/*.{h,swift}', 'RxLifxApi/RxLifxApi/Command/*.swift'
end
