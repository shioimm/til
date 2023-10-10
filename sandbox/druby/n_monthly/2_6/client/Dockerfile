FROM rubylang/ruby

RUN gem install webrick

ADD ./2_6_2_irb_c.rb /irb_c.rb

ENTRYPOINT ["ruby", "irb_c.rb"]
