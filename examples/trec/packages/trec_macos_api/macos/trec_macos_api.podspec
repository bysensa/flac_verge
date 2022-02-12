#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint trec_macos_api.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'trec_macos_api'
  s.version          = '0.0.1'
  s.summary          = 'Plugin for platform api required by Trec app'
  s.description      = <<-DESC
Plugin for platform api required by Trec app
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'dev.bysensa@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.dependency 'FlatBuffers'

  s.platform = :osx, '10.15'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.5'
end
