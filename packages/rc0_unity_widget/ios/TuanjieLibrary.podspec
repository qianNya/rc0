Pod::Spec.new do |s|
  s.name             = 'TuanjieLibrary'
  s.version          = '1.0.0'
  s.summary          = 'Tuanjie/Unity iOS runtime for RC0'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'RC0' => 'dev@rc0.app' }
  s.homepage         = 'https://github.com/rc0/rc0'
  s.source           = { :git => 'https://github.com/rc0/rc0.git', :tag => s.version.to_s }
  s.platform         = :ios, '14.0'

  pod_root = File.dirname(__FILE__)
  unity_ios = File.expand_path('../../../unity/rc0_runtime/ios', pod_root)
  device_fw = '../../../unity/rc0_runtime/ios/build/Release-iphoneos/TuanjieFramework.framework'
  sim_fw = '../../../unity/rc0_runtime/ios/build/Release-iphonesimulator/TuanjieFramework.framework'
  device_ready = File.exist?(File.join(unity_ios, 'build/Release-iphoneos/TuanjieFramework.framework/TuanjieFramework'))
  sim_ready = File.exist?(File.join(unity_ios, 'build/Release-iphonesimulator/TuanjieFramework.framework/TuanjieFramework'))

  s.subspec 'Stub' do |stub|
    stub.source_files = 'Stub/**/*.{m,mm}'
    stub.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '$(inherited) -D RC0_TUANJIE_STUB',
    }
  end

  s.subspec 'Full' do |full|
    frameworks = []
    frameworks << device_fw if device_ready
    frameworks << sim_fw if sim_ready
    full.vendored_frameworks = frameworks unless frameworks.empty?

    xcconfig = {
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
      'OTHER_SWIFT_FLAGS[sdk=iphonesimulator*]' => '$(inherited) -D RC0_TUANJIE_STUB',
    }
    user_xcconfig = {}
    if device_ready
      xcconfig.merge!({
        'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphoneos"',
        'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework TuanjieFramework',
      })
      user_xcconfig.merge!({
        'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphoneos"',
        'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework TuanjieFramework',
      })
    end
    if sim_ready
      xcconfig.merge!({
        'FRAMEWORK_SEARCH_PATHS[sdk=iphonesimulator*]' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphonesimulator"',
        'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -framework TuanjieFramework',
        'OTHER_SWIFT_FLAGS[sdk=iphonesimulator*]' => '$(inherited)',
      })
      user_xcconfig.merge!({
        'FRAMEWORK_SEARCH_PATHS[sdk=iphonesimulator*]' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphonesimulator"',
        'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -framework TuanjieFramework',
      })
    end
    full.pod_target_xcconfig = xcconfig
    full.user_target_xcconfig = user_xcconfig unless user_xcconfig.empty?
  end

  s.default_subspec = 'Stub'
end
