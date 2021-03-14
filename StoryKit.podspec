#
# Be sure to run `pod lib lint StoryKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StoryKit'
  s.version          = '0.1.3'
  s.summary          = 'edit story for SNS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'cocoaPod project'

  s.homepage         = 'https://github.com/2jeje/StoryKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '2jeje' => 'bbabbi01@gmail.com' }
  s.source           = { :git => 'https://github.com/2jeje/StoryKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'StoryKit/Classes/**/*'
  s.swift_version = '5.0'
  s.resources = 'StoryKit/Assets/*.{png,jpeg,jpg,storyboard,xib,xcassets}'
   #s.resource_bundles = {
   #  'StoryKit' => ['StoryKit/asset.xcassets']
   #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
