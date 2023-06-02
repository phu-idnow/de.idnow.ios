source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'

target 'IDnow' do
  use_frameworks!
#  use_frameworks! :linkage => :static
  pod 'IDnowSDK', '6.6.0'
  pod 'Masonry', '~> 1.1.0'
  pod 'libPhoneNumber-iOS', '~> 0.9'
  pod 'FLAnimatedImage', '~> 1.0'
  pod 'AFNetworking', '~> 4.0'
  pod 'lottie-ios', '~> 2.5'
#  pod 'IDnowSDK', :path => '../idnow-sdk/IDnowSDK.podspec'
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
         end
    end
  end
end
