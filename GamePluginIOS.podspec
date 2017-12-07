#
# Be sure to run `pod lib lint GamePluginIOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GamePluginIOS'
  s.version          = '0.5.6'
  s.summary          = 'GamePluginIOS'
  s.description      = <<-DESC
GamePluginIOS.
                       DESC
  s.homepage         = 'https://github.com/ietstudio/GamePluginIOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'gaoyang' => 'gaoyang@joycastle.mobi' }
  s.source           = { :git => 'https://github.com/ietstudio/GamePluginIOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '7.0'

  s.source_files = 'GamePluginIOS/Classes/**/*'
  s.resource_bundles = {
    'GamePluginIOS' => ['GamePluginIOS/Assets/*.png', 'GamePluginIOS/Assets/*.lproj']
  }

  s.dependency 'GamePluginBase'

  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'MD5Digest', '~> 1.0.1'
  s.dependency 'RMStore', '~> 0.7.1'
  s.dependency 'GameCenterManager', '~> 5.3'
  s.dependency 'Fabric'
  s.dependency 'Crashlytics'
  s.dependency 'FCUUID'
  s.dependency 'UICKeyChainStore', '~> 2.1.0'
end
