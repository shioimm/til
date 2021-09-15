# 操作
- `uploads/book/`フォルダ内に格納されているファイルを`store/uploads/book/`フォルダ内へ再起的にコピー
```
$ aws s3 cp s3://aws-review-apps/uploads/book s3://aws-review-apps/store/uploads/book/ --recursive --profile start-aws-user
```

- URLを知っていればは誰でもアクセス可能
```
$ aws s3 cp s3://aws-review-apps/uploads/book s3://aws-review-apps/store/uploads/book/ --recursive --profile start-aws-user --acl public-read
```

## 参照
- [AWS CLI での Amazon S3 の使用](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-services-s3.html)
