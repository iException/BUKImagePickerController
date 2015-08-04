Pod::Spec.new do |s|
  s.name             = "BUKImagePickerController"
  s.version          = "0.1.2"
  s.summary          = "A controller helps you select images from a camera or a photo library."
  s.homepage         = "https://github.com/iException/BUKImagePickerController"
  s.license          = 'MIT'
  s.author           = { "Yiming Tang" => "yimingnju@gmail.com" }
  s.source           = { :git => "https://github.com/iException/BUKImagePickerController.git", :tag => "v#{s.version.to_s}" }
  s.social_media_url = 'https://twitter.com/yiming_t'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'BUKImagePickerController/Classes/**/*'
  s.resources = ["BUKImagePickerController/Assets/*.{png,xcassets}"]

  s.frameworks = 'AssetsLibrary'
  s.dependency 'FastttCamera', '~> 0.3'
end
