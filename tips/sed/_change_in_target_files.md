# 対象の全ファイル中の該当文言を修正する

```
# Macの場合は-iの後に""が必要

$ find . -name FILE_NAME | xargs sed -i "" 's/BEFORE/AFTER/g'
```
