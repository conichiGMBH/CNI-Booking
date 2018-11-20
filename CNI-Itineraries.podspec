#
# Be sure to run `pod lib lint CNI-Booking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CNI-Itineraries'
  s.version          = '1.0.11'
  s.swift_version    = '3.2'
  s.summary          = 'provide methods to push, retrieve and delete bookings from conichi backend'

  s.description      = <<-DESC
                          Provide methods to push, retrieve and delete bookings from conichi backend
                          Read README file for usage
                          DESC

  s.homepage         = 'https://github.com/conichiGMBH/CNI-Booking'
  s.license          = { :type => 'Conichi License', :file => 'LICENSE' }
  s.author           = { 'Joseph Tseng' => 'joseph.tseng@conichi.com' }
  s.source           = { :git => 'https://github.com/conichiGMBH/CNI-Booking.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'CNI-Booking/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CNI-Booking' => ['CNI-Booking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
