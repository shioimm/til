hfcal.o: p366_hfcal.c
	gcc -I/includes -c p366_hfcal.c -o hfcal.o
main.o: p366_main.c
	gcc -I/includes -c p366_main.c -o main.o
libhfcal.so: hfcal.o
	gcc -shared hfcal.o -o /includes/libs/libhfcal.so
main: libhfcal.a main.o
	gcc main.o -L/includes/libs -lhfcal -o main
