class TestSocket < Test::Unit::TestCase
  # ...
  def test_tcp_fast_fallback
    opts = %w[-rsocket -W1]
    assert_separately opts, <<~RUBY
    assert_true(Socket.tcp_fast_fallback)

    Socket.tcp_fast_fallback = false
    assert_false(Socket.tcp_fast_fallback)

    Socket.tcp_fast_fallback = true
    assert_true(Socket.tcp_fast_fallback)
    RUBY
  end
end
