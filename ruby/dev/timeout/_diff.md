# 案
- メソッド開始時点からのタイムアウト `open_timeout`
- Resolution Delay中、Connection Attempt Delay中の場合はよりタイムアウト時間が短い方を取る
- 既存のタイムアウト値と同時に設定した場合は例外を上げる
