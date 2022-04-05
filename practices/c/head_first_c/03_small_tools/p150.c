// Head First C P150

#include <stdio.h>
#include <unistd.h> // getopt()

// $ gcc p150.c -o p150 && ./p150 -d now -t Anchovies
int main(int argc, char *argv[])
{
  char *delivery = "";
  int thick = 0;
  int count = 0;
  char ch;

  while ((ch = getopt(argc, argv, "d:t")) != EOF) { // : = 引数が必要
    switch (ch) {
      case 'd':
        delivery = optarg; // 引数を渡す
        break;
      case 't':
        thick = 1;
        break;
      default:
        fprintf(stderr, "Unknown option: '%s'\n", optarg);
        return 1;
    }
  }

  // optind - オプションを読み飛ばすためにコマンドラインから読み込んだ文字列数
  argc -= optind;
  argv += optind;

  if (thick) {
    puts("Thick crust.");
  }
  if (delivery[0]) {
    printf("To be delivered %s.\n", delivery);
  }

  puts("Ingredients: ");

  for (count = 0; count < argc; count++) {
    puts(argv[count]);
  }

  return 0;
}
