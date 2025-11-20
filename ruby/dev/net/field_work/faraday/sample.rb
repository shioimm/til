require "faraday"

GEM_PATH = ENV["RBENV_ROOT"] + "/versions/" + ENV["RBENV_VERSION"] + "/lib/ruby/gems/"

TracePoint.trace(:call) do |tp|
  if tp.path.include? "faraday"
    p [tp.self.class, tp.defined_class, tp.method_id, "#{tp.path.gsub(GEM_PATH, "")}:#{tp.lineno}"]
  end
end

Faraday.new(url: "http://example.com").get("/index.html")

__END__
client = Faraday.new(url: "http://example.com")
res = client.get "/index.html"
puts res.body
puts("---")
p client.class # Faraday::Connection
p res.class # Faraday::Response
p res.status
pp res.headers # Faraday::Utils::Headers
p res.headers["content-type"]
p res.headers["last-modified"]
