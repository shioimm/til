# マイグレーションの変更をコミットログへrebaseする
1. 修正したい状態までマイグレーションをロールバックしておく
2. マイグレーションファイルを修正
3. `$ rails db:migrate`
4. `$ git add -A`
5. `$ git commit --fixup <対象のコミットのハッシュ番号>`
6. `$ git rebase -i --autosquash HEAD~<最新のコミットを含めて対象のコミットまで数えた数>`
