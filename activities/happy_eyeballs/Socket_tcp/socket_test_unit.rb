# frozen_string_literal: true

# Socket.tcpの動作を検証しているテスト項目
#   #test_accept_loop
#   #test_accept_loop_multi_port
#   #test_connect_timeout
#
# 追加するテスト項目
#   名前解決の検証
#     先にIPv6 addrinfoを取得した場合 -> assert_true(ipv6?)
#     先にIPv4 addrinfoを取得した場合 -> assert_true(ipv4?)
#     先にIPv4 addrinfoを取得したが、Resolution Delay中にIPv6 addrinfoを取得した場合 -> assert_true(ipv6?)
#  接続の検証
#     IPv6 addrinfo -> IPv4 addrinfoの順でconnectを開始し、先にIPv4 addrinfoで接続確立した場合 -> assert_true(ipv4?)
#  エラーの検証
#     名前解決中にresolv_timeoutがタイムアウトした場合 -> assert_raise(Errno::ETIMEDOUT)
#     Aレコードの取得に失敗した後AAAAレコードの取得に成功した場合 -> assert_nothing_raised
#     名前解決がSocketErrorで失敗した場合 -> assert_raise_with_message(SocketError, ...) (最後のmessageを取得)

require "test/unit"
require_relative "./socket"

class SocketTest < Test::Unit::TestCase
end
