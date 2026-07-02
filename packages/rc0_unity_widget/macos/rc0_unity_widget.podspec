Pod::Spec.new do |s|
  s.name             = 'rc0_unity_widget'
  s.version          = '0.1.0'
  s.summary          = 'RC0 Unity embed for Flutter macOS'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'RC0' => 'dev@rc0.app' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
  s.preserve_paths = 'UnityPlayer/**/*'
  s.resource_bundles = { 'Rc0UnityPlayer' => ['UnityPlayer/**/*'] }
end
