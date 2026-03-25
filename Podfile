platform :osx, '13.0'

target 'Cast' do
  use_frameworks!

  pod 'google-cast-sdk', '~> 4.8'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['MACOSX_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
