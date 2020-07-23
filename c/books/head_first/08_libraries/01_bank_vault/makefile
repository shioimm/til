# 引用: head first c
# 第8章 スタティックライブラリとダイナミックライブラリ 1

# encrypt.cからオブジェクトファイルencrypt.oを生成
encrypt.o: encrypt.c
	gcc -c encrypt.c -o encrypt.o

# checksum.cからオブジェクトファイルchecksum.oを生成
checksum.o: checksum.c
	gcc -c checksum.c -o checksum.o

# encrypt.oとchecksum.oからアーカイブファイルlibhfsecurity.aを生成
libhfsecurity.a: encrypt.o checksum.o
	ar -rcs libhfsecurity.a encrypt.o checksum.o

# bank_vault.c libhfsecurity.aから実行ファイルbank_vaultを生成し、実行
bank_vault: bank_vault.c libhfsecurity.a
	gcc bank_vault.c -I. -L. -lhfsecurity -o bank_vault
# -I.          -> カレントディレクトリ内のヘッダファイルの探索を指示
# -L.          -> カレントディレクトリ内のアーカイブファイルの探索を指示
# -lhfsecurity -> hfsecurityと名前が一致するアーカイブファイルの探索を指示
