require "httpx"

HOST1 = "http://example.com"
HOST2 = "https://google.com"

responses = HTTPX.get(HOST1)#, HOST2)

p responses

__END__
[
  #<Response:240 HTTP/2.0
    @status=200
    @headers={
      "accept-ranges" => ["bytes"], "content-type" => ["text/html"],
      "etag" => ["\"84238dfc8092e5d9c0dac8ef93371a07:1736799080.121134\""],
      "last-modified" => ["Mon, 13 Jan 2025 20:11:20 GMT"], "vary" => ["Accept-Encoding"],
      "content-encoding" => ["gzip"], "content-length" => ["648"],
      "cache-control" => ["max-age=86000"], "date" => ["Thu, 09 Oct 2025 10:29:59 GMT"],
      "alt-svc" => ["h3=\":443\"; ma=93600"]
    }
    @body=1256>,
  #<Response:248 HTTP/2.0
    @status=301
    @headers={
      "location" => ["https://www.google.com/"],
      "content-type" => ["text/html; charset=UTF-8"],
      "content-security-policy-report-only" => [
        "object-src 'none';base-uri 'self';script-src 'nonce-d95-7porZbUnHY3nBMAvFQ' 'strict-dynamic' 'report-sample'
        'unsafe-eval' 'unsafe-inline' https: http:;report-uri https://csp.withgoogle.com/csp/gws/other-hp"
      ],
      "date" => ["Thu, 09 Oct 2025 10:29:58 GMT"], "expires" => ["Sat, 08 Nov 2025 10:29:58 GMT"],
      "cache-control" => ["public, max-age=2592000"],
      "server" => ["gws"], "content-length" => ["220"],
      "x-xss-protection" => ["0"], "x-frame-options" => ["SAMEORIGIN"],
      "alt-svc" => ["h3=\":443\"; ma=2592000,h3-29=\":443\"; ma=2592000"]
    }
    @body=220>
]
