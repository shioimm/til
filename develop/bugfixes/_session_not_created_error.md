# [CircleCI]Selenium::WebDriver::Error::SessionNotCreatedError:
## 挙動
- `session not created: This version of ChromeDriver only supports Chrome version 78`でテストが落ちる

## 原因
- CircleCIが利用しているChromeのバージョン(Docker Image)が上がったため

## 対策
- 開発側のChromeDriverのバージョンを追随させる
  - Webdriverでバージョンを固定していたため、バージョン固定の行を削除
  - ローカルでテストを実行できるように自分のPCのChromeのバージョンとChromeDriverのバージョンも上げる
