# Husky
- `git commit` `git push`などコマンドの実行にフックして任意の処理を走らせる

### 用途
- コミット前にlinterとテストを実行するなど

### Usage
- package.jsonに実行したい処理を記述
```
{
  "husky": {
    "hooks": {
      "pre-commit": "npm test",
      "pre-push": "npm test",
      "...": "..."
    }
  }
}
```

## 参照
- [husky](https://github.com/typicode/husky)
