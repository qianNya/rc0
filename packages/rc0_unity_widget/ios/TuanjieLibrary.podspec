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

  s.subspec 'Stub' do |stub|
    stub.source_files = 'Stub/**/*.{m,mm}'
    stub.pod_target_xcconfig = {
      'OTHER_SWIFT_FLAGS' => '$(inherited) -D RC0_TUANJIE_STUB',
    }
  end

  s.subspec 'Full' do |full|
    frameworks = []
    if File.exist?(File.join(unity_ios, 'build/Release-iphoneos/TuanjieFramework.framework/TuanjieFramework'))
      frameworks << device_fw
    end
    if File.exist?(File.join(unity_ios, 'build/Release-iphonesimulator/TuanjieFramework.framework/TuanjieFramework'))
      frameworks << sim_fw
    end

    unless frameworks.empty?
      full.vendored_frameworks = frameworks
    end

    # Data must live inside TuanjieFramework.framework/Data (IL2CPP reads
    # .../TuanjieFramework.framework/Data/Managed/Metadata/global-metadata.dat).
    # Bundled by scripts/build_tuanjie_ios.sh after xcodebuild.

    full.pod_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphoneos" "$(PODS_ROOT)/../UnityLibrary/build/Release-iphonesimulator"',
      'OTHER_LDFLAGS' => '$(inherited) -framework TuanjieFramework',
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    }
    full.user_target_xcconfig = {
      'FRAMEWORK_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/../UnityLibrary/build/Release-iphoneos" "$(PODS_ROOT)/../UnityLibrary/build/Release-iphonesimulator"',
      'OTHER_LDFLAGS' => '$(inherited) -framework TuanjieFramework',
    }
  end

  s.default_subspec = 'Stub'
end
