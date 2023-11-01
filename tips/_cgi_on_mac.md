### `/etc/apache2/httpd.conf`変更箇所
```
LoadModule cgi_module libexec/apache2/mod_cgi.so
```

```
AddHandler cgi-script .cgi .rb
```

```
ServerName localhost:80
```

### `/Library/WebServer/CGI-Executables/test.rb`

```
$ sudo chmod 755 /Library/WebServer/CGI-Executables/test.rb
```

```ruby
#!/usr/bin/ruby
print "Content-Type: text/html\n\n"
str = "Hello World"
print str
print "\n"
```

# 参照
- [Ruby CGIをローカルからcurlを送りテストしたい](https://teratail.com/questions/317012)
- [ApacheでRubyスクリプトにアクセスするとShebangでエラーが出る。](https://teratail.com/questions/172038)
