Pod::Spec.new do |spec|
  spec.name = 'URITemplate'
  spec.version = '0.1.0'
  spec.summary = 'Swift library for dealing with URI Templates (RFC6570)'
  spec.homepage = 'https://github.com/kylef/URITemplate.swift'
  spec.license = { :type => 'MIT', :file => 'LICENSE' }
  spec.author = { 'Kyle Fuller' => 'inbox@kylefuller.co.uk' }
  spec.social_media_url = 'http://twitter.com/kylefuller'
  spec.source = { :git => 'https://github.com/kylef/URITemplate.swift.git', :tag => "#{spec.version}" }
  spec.source_files = 'URITemplate/*.{h,swift}'
end

