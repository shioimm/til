FROM rubylang/ruby

RUN gem install webrick

ADD ./2_6_2_min.rb /min.rb

EXPOSE 8000

CMD ["ruby", "min.rb"]
