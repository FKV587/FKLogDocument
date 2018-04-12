Pod::Spec.new do |s|

  s.name         = "FKLogDocument"
  s.version      = "0.0.1"
  s.summary      = "log日志保存到沙盒"

  s.description  = <<-DESC
       所有log日志保存到沙盒
                   DESC

  s.homepage     = "https://github.com/FKV587/FKLogDocument"
  s.license      = "MIT"
  s.author       = { "chrislian" => "263699451@qq.com" }
  s.platform     = :ios,'8.0'

  s.source       = { :git => "https://github.com/FKV587/FKLogDocument.git", :tag => "#{s.version}" }
  s.source_files = "FKLogDocument/*.{h,m}"
  s.framework    = "Foundation"
  s.requires_arc = true
end
