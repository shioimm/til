// Linuxによる並行プログラミング入門 P64

#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <stdlib.h>
#include <string.h>

int main()
{
  struct msbbuf {
    long mtype;
    char mtext[80];
  };

  key_t  key;
  int    queid;
  struct msbbuf msg;

   key   = ftok("practices/concurrent_programming_with_linux_101/", 'a');
   queid = msgget(key, 0666);

   for (;;) {
     if (msgrcv(queid, &msg, 80, 2, 0) == -1) exit(0);

     puts(msg.mtext);

     puts("message ?");

     if (fgets(msg.mtext, 80, stdin) == NULL) exit(0);

     msg.mtype = 1;
     msgsnd(queid, &msg, strlen(msg.mtext) + 1.0, 0);
   }
}
