// Linuxによる並行プログラミング入門 P63

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
   queid = msgget(key, 0666 | IPC_CREAT);

   for (;;) {
     puts("message");

     if (fgets(msg.mtext, 80, stdin) == NULL) exit(0);

     if (strncmp(msg.mtext, "end", 3) == 0) {
       msgctl(queid, IPC_RMID, 0);
       exit(0);
     }

     msg.mtype = 2;
     msgsnd(queid, &msg, strlen(msg.mtext) + 1.0, 0);
     msgrcv(queid, &msg, 80, 1, 0);
     puts(msg.mtext);
   }
}
