# 参照: dRubyによる分散・Webプログラミング

require 'cgi'
require 'erb'
require 'drb/drb'

class UnknownErrorPage
  include ERB::Util

  def initialize(error=$!, info=$@)
    @erb   = ERB.new(erb_src)
    @error = error
    @info  = info
  end

  def erb_src
    <<EOS
<p><%= h @error %> = <%= h @error.class %></p>
<ul>
<% @info.each do |line| %>
<li><%= h line %></li>
<% end %>
</ul>
EOS
  end

  def to_html
    @erb.result(binding)
  end
end

def main
  DRb.start_service
  reminder = DRbObject.new_with_uri('druby://localhost:12346')
  cgi = CGI.new('html5')

  begin
    reminder.do_request(cgi)
    content = reminder.to_html(cgi)
  rescue
    content = UnknownErrorPage.new($!, $@).to_html
  end

  cgi.out({ 'charset' => 'utf-8' }) {
    cgi.html {
      cgi.head {
        cgi.title { 'Reminder' }
      } + cgi.body { content }
    }
  }
end

main
