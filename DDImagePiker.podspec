Pod::Spec.new do |s|  
  s.name             = "DDImagePiker"  
  s.version          = "0.0.2"  
  s.summary          = "Used for the selection of images in assetlibrary or takePhoto."  
  s.homepage         = "https://github.com/393385724/DDImagePiker"  
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"  
  s.license          = 'MIT'  
  s.author           = { "llg" => "393385724@qq.com" }  
  s.source           = { :git => "https://github.com/393385724/DDImagePiker.git", :tag => s.version.to_s }  
  # s.social_media_url = ''  
  
  s.platform     = :ios, '7.0'  
  s.ios.deployment_target = '7.0'  
  # s.osx.deployment_target = '10.7'  
  s.requires_arc = true  
  
  s.source_files = 'DDImagePiker/**/**/*.{h,m}' 
  s.resources = 'DDImagePiker/**/**/*.{png,jpeg,jpg,xib,xcassets}'
  
  s.frameworks = 'Foundation', 'CoreGraphics', 'UIKit','Photos','AssetsLibrary','AVFoundation','UIKit'
  s.dependency 'DDCoreCategory'
end  
