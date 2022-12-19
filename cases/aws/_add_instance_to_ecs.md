# ECSクラスタにEC2インスタンスを追加した後、追加したインスタンスがクラスタに登録されない
1. 該当のインスタンスにssh
2. `/etc/ecs/ecs.config`を作成
  -  `ecs.config`の内容は登録済みのインスタンスからコピーする
3. ecs-agentを再起動 (`$ sudo systemctl restart ecs`)
4. `/var/log/ecs/ecs-agent.log`に出力されているエラーを確認
    - `/var/lib/ecs/data`を削除
5. ecs-agentを再起動 (`$ sudo systemctl restart ecs`)

## 参照
- [【小ネタ】ECS(EC2)を利用する時にクラスターへ参加出来ない時の対処](https://dev.classmethod.jp/articles/ecsec2_cluster_failed/)
