require 'erb'
require 'fileutils'

module XlsxWriter
  class Xml
    attr_reader :document

    def initialize(document)
      @document = document
      @mutex = ::Mutex.new
    end

    def generate
      path
      true
    end

    def generated?
      @generated == true
    end
    
    def path
      @path || @mutex.synchronize do
        @path ||= begin
          memo = ::File.join document.staging_dir, relative_path
          ::FileUtils.mkdir_p ::File.dirname(memo)
          ::File.open(memo, 'wb') do |f|
            f.write render
          end
          converted = ::UnixUtils.unix2dos memo
          ::FileUtils.mv converted, memo
          @generated = true
          memo
        end
      end
    end
        
    def template_path
      ::File.expand_path "../generators/#{self.class.name.demodulize.underscore}.erb", __FILE__
    end
    
    def render
      ::ERB.new(::File.read(template_path), nil, '<>').result(binding)
    end
  end
end
