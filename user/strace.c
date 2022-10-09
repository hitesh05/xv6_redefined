#include "../kernel/param.h"
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"

int main(int argc, char **argv)
{
    if (argc < 3)
    {
        fprintf(2, "strace: Invalid syntax\n");
        exit(1);
    }

    int mask = atoi(argv[1]);
    trace(mask);

    int num = argc - 2;
    char *args_new[num + 1];
    for (int i = 0; i < num; i++)
    {
        args_new[i] = argv[i + 2];
    }

    args_new[num] = 0;
    exec(args_new[0], args_new);
    fprintf(2, "strace: %s exec failed\n", args_new[0]);
    exit(0);
}