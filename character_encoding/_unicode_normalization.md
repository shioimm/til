# Unicode正規化
## 正規化形式
#### NFD (Normalization Form D)
- 正規化形式D (Decomposition)
- 書記素を可能な限り分解し、基本文字 + ダイアクリティカルマーク (発音記号など) の組み合わせにする
- 一つのコードポイントであった文字を複数のコードポイントに展開する

#### NFC (Normalization Form C)
- 正規化形式C (Composition)
- NFDで分解した文字を可能な限り合成し直して一つの文字にする
- Unicodeが推奨する正規化形式

#### NFKD (Normalization Form KD)
- 互換正規化形式D (Compatibility Decomposition)
- 書記素を可能な限り分解し、その際に互換文字を基本的な文字形へと変換するルールを適用した上で
  基本文字 + ダイアクリティカルマーク (発音記号など) の組み合わせにする

#### NFKC (Normalization Form KC)
- 互換正規化形式C (Compatibility Composition)
- NFKDで分解および互換変換した文字を可能な限り合成し直して一つの文字にする

### 用途
- 厳密に文字を区別して統一する -> NFC or NFD
- 見た目や幅の差異をなくして一律に比較・検索する -> NFKC or NFKD

```ruby
"a\u0300".unicode_normalize(:nfkc)
```
