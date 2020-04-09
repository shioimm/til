# 内部構造(2020-04-09)
```
 rack/
 ├── auth
 │   ├── abstract
 │   │   ├── handler.rb
 │   │   └── request.rb
 │   ├── basic.rb
 │   └── digest
 │       ├── md5.rb
 │       ├── nonce.rb
 │       ├── params.rb
 │       └── request.rb
 ├── body_proxy.rb
 ├── builder.rb
 ├── cascade.rb
 ├── chunked.rb
 ├── common_logger.rb
 ├── conditional_get.rb
 ├── config.rb
 ├── content_length.rb
 ├── content_type.rb
 ├── core_ext
 │   └── regexp.rb
 ├── deflater.rb
 ├── directory.rb
 ├── etag.rb
 ├── events.rb
 ├── file.rb
 ├── files.rb
 ├── handler
 │   ├── cgi.rb
 │   ├── fastcgi.rb
 │   ├── lsws.rb
 │   ├── scgi.rb
 │   ├── thin.rb
 │   └── webrick.rb
 ├── handler.rb
 ├── head.rb
 ├── lint.rb
 ├── lobster.rb
 ├── lock.rb
 ├── logger.rb
 ├── media_type.rb
 ├── method_override.rb
 ├── mime.rb
 ├── mock.rb
 ├── multipart
 │   ├── generator.rb
 │   ├── parser.rb
 │   └── uploaded_file.rb
 ├── multipart.rb
 ├── null_logger.rb
 ├── query_parser.rb
 ├── recursive.rb
 ├── reloader.rb
 ├── request.rb
 ├── response.rb
 ├── rewindable_input.rb
 ├── runtime.rb
 ├── sendfile.rb
 ├── server.rb
 ├── session
 │   ├── abstract
 │   │   └── id.rb
 │   ├── cookie.rb
 │   ├── memcache.rb
 │   └── pool.rb
 ├── show_exceptions.rb
 ├── show_status.rb
 ├── static.rb
 ├── tempfile_reaper.rb
 ├── urlmap.rb
 ├── utils.rb
 └── version.rb
 rack.rb
```
