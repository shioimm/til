# Namespace
- システム上のリソースを名前空間によって分離し、プロセスに対して見かけ上独立したリソース空間を提供する機能

#### コンテナ
- 各namespace内の独立したリソースにアタッチされることによって他のプロセスから分離した実行環境を持つプロセス

## 種類

| 名前空間 | 分離対象                                   |
| -        | -                                          |
| IPC      | System V IPC, POSIX メッセージキュー       |
| Network  | ネットワークデバイス、スタック、ポートなど |
| Mount    | マウントポイント                           |
| PID      | プロセス ID                                |
| User     | ユーザー ID とグループ ID                  |
| UTS      | ホスト名と NIS ドメイン名                  |