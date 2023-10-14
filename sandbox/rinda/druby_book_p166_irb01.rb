require 'drb'

DRb.start_service
$ts = DRbObject.new_with_uri('druby://localhost:12345')
$ts.write(['take-test', 1])    # C-Lindaのout操作
p $ts.take(['take-test', nil]) # C-Lindaのin操作 ('take-test'がなければブロック) / => ["take-test", 1]
p $ts.take(['take-test', nil]) # irb02でタプルスペースに新たに'take-test'がwriteされるまでブロック
$ts.write(['take-test-1', 1]) # irb02でタプルスペースに新たに'take-test'がwriteされるまでブロック

# irb01とirb02はタプルスペースを経由して通信する
