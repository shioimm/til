# Elasticsearch
- 分散型RESTful検索/分析エンジン

### 特徴
- 全文検索
- 検索の速さ
- スケーラビリティ

## Get Started
```
$ brew tap elastic/tap
$ brew install elastic/tap/elasticsearch-full

# 日本語の形態素解析エンジンを追加
$ elasticsearch-plugin install analysis-kuromoji

# 起動
$ elasticsearch
```

## 参照
- [Elasticsearch](https://www.elastic.co/jp/elasticsearch/)
- パーフェクトRuby on Rails[増補改訂版] P395
