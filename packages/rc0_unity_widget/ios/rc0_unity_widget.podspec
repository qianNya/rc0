Pod::Spec.new do |s|
  s.name             = 'rc0_unity_widget'
  s.version          = '0.1.0'
  s.summary          = 'RC0 Unity embed for Flutter'
  s.description      = 'PlatformView + bridge for Unity 3D runtime'
  s.homepage         = 'https://github.com/rc0/rc0'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'RC0' => 'dev@rc0.app' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'

  pod_root = File.dirname(__FILE__)
  unity_ios = File.expand_path('../../../unity/rc0_runtime/ios', pod_root)
  device_fw = File.join(unity_ios, 'build/Release-iphoneos/TuanjieFramework.framework/TuanjieFramework')
  tuanjie_subspec = ENV.fetch('RC0_TUANJIE_SUBSPEC') {
    File.exist?(device_fw) ? 'Full' : 'Stub'
  }
  s.dependency "TuanjieLibrary/#{tuanjie_subspec}"

  pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
  }
  if tuanjie_subspec == 'Full'
    pod_target_xcconfig.merge!({
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphoneos" "$(PODS_ROOT)/../UnityLibrary/build/Release-iphonesimulator"',
      'OTHER_LDFLAGS' => '$(inherited) -framework TuanjieFramework',
    })
  else
    pod_target_xcconfig['OTHER_SWIFT_FLAGS'] = '$(inherited) -D RC0_TUANJIE_STUB'
  end
  s.pod_target_xcconfig = pod_target_xcconfig
  s.platform = :ios, '14.0'
  s.swift_version = '5.0'
end
