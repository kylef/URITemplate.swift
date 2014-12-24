Pod::Spec.new do |spec|
  spec.name = 'URITemplate'
  spec.version = '1.0.1'
  spec.summary = 'Swift library for dealing with URI Templates (RFC6570)'
  spec.homepage = 'https://github.com/kylef/URITemplate.swift'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'inbox@kylefuller.co.uk' }
  spec.social_media_url = 'http://twitter.com/kylefuller'
  spec.source = { :git => 'https://github.com/kylef/URITemplate.swift.git', :tag => "#{spec.version}" }
  spec.source_files = 'URITemplate/*.{h,swift}'
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.requires_arc = true
end

