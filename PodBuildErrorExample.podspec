Pod::Spec.new do |s|
s.name         = "PodBuildErrorExample"
s.version      = "0.0.1"
s.authors      = "PodBuildErrorExample"
s.homepage     = "http://www.PodBuildErrorExample.com"
s.license      = { }
s.summary      = "PodBuildErrorExample"
s.source       = { :git => "https://github.com/richmondwatkins/PodBuildErrorExample", :tag => "#{s.version}" }
s.ios.deployment_target = '8.0'
s.source_files = "PodBuildErrorExample/**/*.{swift}"
s.resources    = "PodBuildErrorExample/**/*.{png,jpeg,jpg,gif,storyboard,xib,lproj,xcdatamodeld,plist,xcassets}"
s.frameworks = "Photos"
end