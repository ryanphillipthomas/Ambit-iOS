# Uncomment this line to define a global platform for your project
# platform :ios, '10.0'

  def shared_pods
    pod 'Fabric', '1.6.8'
    pod 'Crashlytics', '3.8.0'
    pod 'AudioPlayerSwift'
    pod 'Spring', :git => 'https://github.com/MengTo/Spring.git', :branch => 'swift3'
  end

target 'Ambit' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Ambit
  shared_pods

  target 'AmbitTests' do
      # Pods for testing
    inherit! :search_paths
    shared_pods
  end

  target 'AmbitUITests' do
      # Pods for testing
    inherit! :search_paths
    shared_pods
  end
end

target 'TV' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TV
  shared_pods

  target 'TVTests' do
      # Pods for testing
    inherit! :search_paths
    shared_pods
  end

  target 'TVUITests' do
      # Pods for testing
    inherit! :search_paths
    shared_pods
  end
end
