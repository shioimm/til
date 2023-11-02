# `rails`コマンドの実行に失敗する
```
$ rails db:migrate
rails aborted!
LoadError: dlopen(/Users/misakishioi/WORKINGDIR/vendor/bundle/ruby/2.7.0/gems/charlock_holmes-0.7.7/lib/charlock_holmes/charlock_holmes.bundle, 9): Library not loaded: /usr/local/opt/icu4c/lib/libicudata.67.dylib
```

- 数日前MacOSのアップグレードを実行
- 直前にHomebrewで新しいパッケージをインストールしており、その際にHomebrewのパッケージがアップグレードされていた

```
$ brew upgrade

# => xcodeがインストールされていないため複数パッケージのアップグレードに失敗

$ xcode-select --instal
$ brew upgrade

# => 成功

# native extensionの依存するパッケージの向き先を更新するため、gemを再インストールする
$ bundle pristine

# => 成功
```
