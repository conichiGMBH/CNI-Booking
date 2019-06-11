# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'CNI-Itineraries' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CNI-Itineraries

  target 'CNI-ItinerariesTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SnapshotTesting', '~> 1.0'
    pod 'Nimble', '~> 8.0'
    pod 'Quick', '~> 1.3'
  end

end

# Thanks http://stackoverflow.com/a/31804504/2487302
post_install do |installer|
  installer.pods_project.targets.each do |target|
    next unless target.name.include?("Pods-")
    next if (target.name.include?("Tests") || target.name.include?("tests"))
    puts "Updating #{target.name}"
    target.build_configurations.each do |config|
      xcconfig_path = config.base_configuration_reference.real_path
      # read from xcconfig to build_settings dictionary
      build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/ *= */, 2)}.flatten]
      # write build_settings dictionary to xcconfig
      File.open(xcconfig_path, "w") do |file|
        file.puts "#include \"../../../config/conichi/Configurations/Common.xcconfig\"\n"
        build_settings.each do |key,value|
          file.puts "#{key} = #{value}"
        end
      end
    end
  end
end
