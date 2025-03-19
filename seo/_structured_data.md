# 構造化データ (Structured Data)
- 検索エンジンに対して当該コンテンツの意味や関係を明示するためのフォーマット
  - 検索エンジン最適化
  - クローラやAIに対してページの内容を伝える
- schema.org の定義に基づき、HTMLに`vocab`、`typeof`、`property`などを付与する
  - `typeof`   = データ型
  - `vocab`    = 語彙の定義 (どのスキーマを基準に解釈するか)
  - `property` = データの属性

```html
<ol class="breadcrumbs__items" typeof="BreadcrumbList" vocab="http://schema.org/">

  <li typeof="ListItem" property="itemListElement">
    <a href="/" property="item" typeof="WebPage">
      <span property="name">ホーム</span>
    </a>
    <meta property="position" content="1">
  </li>

  <li typeof="ListItem" property="itemListElement">
    <a href="/category" property="item" typeof="WebPage">
      <span property="name">カテゴリ</span>
    </a>
    <meta property="position" content="2">
  </li>

  <li typeof="ListItem" property="itemListElement">
    <a href="/category/article" property="item" typeof="WebPage">
      <span property="name">記事</span>
    </a>
    <meta property="position" content="3">
  </li>

</ol>
```
