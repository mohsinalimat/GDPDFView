Pod::Spec.new do |s|
  s.name         = "GDPDFView"
  s.version      = "1.0.3"
  s.summary      = "Vertical scroll view to display PDF file based on using OHPDFImage https://github.com/AliSoftware/OHPDFImage"
  s.homepage     = "https://github.com/dani-gavrilov/GDPDFView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Gavrilov Daniil" => "daniilmbox@gmail.com" }
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/dani-gavrilov/GDPDFView.git", :tag => "1.0.3" }
  s.source_files = "GDPDFView/*"
  s.frameworks = "UIKit", "Foundation"
  s.requires_arc = true
  s.dependency "OHPDFImage"
end
