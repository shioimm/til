encrypt.o: p352_encrypt.c
	gcc -c p352_encrypt.c -o encrypt.o
checksum.o: p352_checksum.c
	gcc -c p352_checksum.c -o checksum.o
libsecurity.a: encrypt.o checksum.o
	ar -rcs libsecurity.a encrypt.o checksum.o
main: p352_main.c libsecurity.a
	gcc p352_main.c -L . -lsecurity -o main
