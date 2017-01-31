# Uncomment this line to define a global platform for your project
platform :ios, '9.0'


target 'QwikStats' do
  pod 'Toast-Swift', '~> 1.3.0'
  pod 'MZFormSheetPresentationController'
  pod 'AKPickerView-Swift'
  pod 'Alamofire', '~> 4.3'
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for QwikStats

  target 'QwikStatsTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'QwikStatsUITests' do
    inherit! :search_paths
    # Pods for testing
  end

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
                config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
                config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            end
        end
    end

end
