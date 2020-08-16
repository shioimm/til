# SearchKick
- 参照: パーフェクトRuby on Rails[増補改訂版] P394-399
- 参照: [searchKick](https://github.com/ankane/searchkick)

## TL;DR
- RailsでElasticsearchを扱うために必要となるDBとElasticsearch間の連携などを担う
  - ElasticsearchはRailsやDBとは別のプロセスで動作し、
    インデックスやドキュメントなどのデータをElasticsearch内部で保持する
    - Elasticsearch - 全文検索エンジン

## Usage
- `gem 'searchkick'`を`$ bundle install`

```ruby
class Xxx < ApplicationRecord
  attr_accessor :yyy, :zzz

  searchkick language: 'japanese' # 検索にKuromojiを使用

  def search_data # Elasticsearchの検索インデックスに追加する情報を定義
    {
      yyy: yyy, # 検索キーワードにマッチさせる情報
      zzz: zzz,
    }
  end
end
```

```
# 事前にElasticsearchをインストール
$ brew tap elastic/tap`
$ brew install elastic/tap/elasticsearch-full`
$ elasticsearch-plugin install analysis-kuromoji`

# Elasticsearchを起動
$ elasticsearch

# 検索インデックスをElasticsearchに登録
$ bin/rails r Xxx.reindex
```

```ruby
# 呼び出し側

Xxx.search((params[:keyword] || '*'), where: { yyy: params[:yyy], zzz: params[:zzz] })
```
