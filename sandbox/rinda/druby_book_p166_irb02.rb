require 'drb'

DRb.start_service
$ts = DRbObject.new_with_uri('druby://localhost:12345')
$ts.write(['take-test', 2])    # C-Lindaのout操作
p $ts.take(['take-test-1', nil]) # irb01でタプルスペースに新たに'take-test-1'がwriteされるまでブロック
