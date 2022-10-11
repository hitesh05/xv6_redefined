#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "../user/user.h"
#include "../kernel/fcntl.h"

int main(int argc,char **argv)
{
    if(argc < 3)
    {
        printf("Invalid command\n");
        exit(0);
    }
    int new_priority = atoi(argv[1]);
    int pid = atoi(argv[2]);
    setpriority(new_priority,pid);
    exit(0);
}