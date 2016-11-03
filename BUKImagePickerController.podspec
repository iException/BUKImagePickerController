Pod::Spec.new do |s|
  s.name             = "BUKImagePickerController"
  s.version          = "0.1.11"
  s.summary          = "A view controller that allows the user picking multiple assets from the photo libray or capturing images with a camera."
  s.homepage         = "https://github.com/iException/BUKImagePickerController"
  s.license          = 'MIT'
  s.author           = { "Yiming Tang" => "yimingnju@gmail.com" }
  s.source           = { :git => "https://github.com/iException/BUKImagePickerController.git", :tag => "v#{s.version.to_s}" }
  s.social_media_url = 'https://twitter.com/yiming_t'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'BUKImagePickerController/Classes/**/*'
  s.resource_bundles = {
    "BUKImagePickerController" => ["BUKImagePickerController/Assets/*.{lproj,png}"]
  }

  s.frameworks = 'AssetsLibrary'
  s.dependency 'FastttCamera', '~> 0.3'
end
