launch.o: launch.c launch.h thruster.h
	gcc -c launch.c

thruster.o: thruster.c thruster.h
	gcc -c thruster.c

launch: launch.o thruster.o
	gcc launch.o thruster.o -o launch
