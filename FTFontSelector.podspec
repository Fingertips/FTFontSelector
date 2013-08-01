Pod::Spec.new do |s|
  s.name         = "FTFontSelector"
  s.version      = "0.1.0"

  s.summary      = "A short description of FTFontSelector."
  s.description  = <<-DESC
                    An optional longer description of FTFontSelector

                    * Markdown format.
                    * Don't worry about the indent, we strip it!
                   DESC

  s.license      = 'MIT'
  s.author       = { "Eloy Durán" => "eloy.de.enige@gmail.com" }

  s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.homepage     = "https://github.com/Fingertips/FTFontSelector"

  s.source       = { :git => "https://github.com/Fingertips/FTFontSelector.git", :tag => s.version.to_s }
  s.platform     = :ios
  s.requires_arc = true

  s.frameworks   = 'CoreText'
  s.source_files = 'Classes', 'Classes/Private'
  s.resource     = 'Assets/FTFontSelector.bundle'

  s.public_header_files = 'Classes/*.h'
end
