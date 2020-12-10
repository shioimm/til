# RailsアプリケーションでCSVファイルを取り扱う
- 参照: 現場で使える Ruby on Rails 5速習実践ガイドP312-317

## 基本
- RubyのCSVを取り扱うために`csv`ライブラリを読み込む
```ruby
# cofig/application.rb

require 'csv'
```

## エクスポート
```ruby
# CSVファイルを取り扱うmodel

class User < ApplicationRecord
  def self.csv_headers
    %w[name email created_at updated_at]
  end

  def self.export_to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_headers

      User.all.each do |user|
        row = csv_headers.map { |attr| user.send(attr) }
        csv << row
      end
    end
  end
end
```

```ruby
# CSVファイルをエクスポートするcontroller
# send_dataにより指定のバイナリデータ(@users.export_csv)をブラウザに送信する

class UsersController < ApplicationController
  def index
    @users = User.all

    respond_to do |format
      format.html
      format.csv { send_data @users.export_to_csv, filename: "users_#{Time.current.strftime('%Y%m%d%S')}.csv" }
    end|
  end
end
```

```haml
# CSVファイルをエクスポートするview
# 拡張子を指定して/users.csvにアクセスする

= link_to 'Export', users_path(format: :csv)
```

## インポート
```ruby
# CSVファイルを取り扱うmodel

class User < ApplicationRecord
  def self.csv_headers
    %w[name email created_at updated_at]
  end

  def self.import_from_csv(file)
    CSV.foreach(file.path, headers: true) do |row|
      csv << csv_headers

      user = User.new
      user.attributes = row.to_hash.slice(*csv_headers)
      user.save!
    end
  end
end
```

```ruby
# CSVファイルをエクスポートするcontroller
# send_dataにより指定のバイナリデータ(@users.export_csv)をブラウザに送信する

class UsersController < ApplicationController
  def import
    User.import_from_csv(params[:file])
    redirect_to users_path
  end
end
```

```ruby
# config/routes.rb
resources :users do
  post :import, on: :collection
end
```

```haml
# CSVファイルをインポートするview
# form_tagでファイルアップロード時はmultipart:trueを指定する

= form_tag import_users_path, multipart: true
  = file_field_tag :file
  = submiot_tag 'Import'
```
