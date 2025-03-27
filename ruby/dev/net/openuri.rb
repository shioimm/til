require "open-uri"

f = URI.open("https://example.com/")
f.each_line { puts it }
puts "---"
p f.class
p f.status
p f.base_uri
p f.content_type
p f.charset
p f.content_encoding
p f.last_modified

__END__
require 'uri'
require 'stringio'
require 'time'

module URI
  def self.open(name, *rest, &block)
    if name.respond_to?(:open)
      name.open(*rest, &block)
    elsif name.respond_to?(:to_str) &&
          %r{\A[A-Za-z][A-Za-z0-9+\-\.]*://} =~ name &&
          (uri = URI.parse(name)).respond_to?(:open)
      uri.open(*rest, &block)
    else
      super
    end
  end

  singleton_class.send(:ruby2_keywords, :open) if respond_to?(:ruby2_keywords, true)
end
