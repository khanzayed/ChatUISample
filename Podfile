platform :ios, '9.0'
use_frameworks!

def shared_pods
    
    pod 'AlamofireImage'
  
end

target 'ChatUISample' do
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end


