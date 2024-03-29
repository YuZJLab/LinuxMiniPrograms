#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <yuzjstd.h>
#include <stdnoreturn.h>
void *print_l();

void tohuman(long inl, char* outstr);

long l = 0;
long t = 0;
int ISMACHINE = 0;
float VERSION=1.1f;


int main(int argc, char *argv[]) {
	for (int i = 0; i < argc; i++) {
		if (! isopt(argv[i])){
			if (strcmp(argv[i], "-h") == 0 | strcmp(argv[i], "--help") == 0) {
				system("man pst");
				return 0;
			} else if (strcmp(argv[i], "-v") == 0 | strcmp(argv[i], "--version") == 0) {
			    printf("Version %f in C\n",VERSION);
                return 0;
            } else if (strcmp(argv[i], "-m") == 0 | strcmp(argv[i], "--machine") == 0) {
                ISMACHINE = 1;
            }
        }
    }
    int a;
    pthread_t thrd1;
    pthread_create(&thrd1, NULL, &print_l, NULL);
    while (EOF != (a = getchar())) {
        putchar(a);
        l++;
    }
    return 0;
}

noreturn void *print_l()
{
    long tmpl;
    long _l = 0;
    if (ISMACHINE) {
        while (1) {
            tmpl = l;
            t++;
            fprintf(stderr, "%ld\t%ld\t%ld\n", l, t, tmpl - _l);
            _l = tmpl;
            sleep(1);
        }
	} else {
        char *lhm = (char*) safe_malloc(100); // Count
        char *ldhm = (char*) safe_malloc(100); // Speed
		while (1) {
			tmpl=l;
			t++;
			tohuman(tmpl,lhm);
			tohuman(tmpl - _l,ldhm);
			fprintf(stderr, "\n\033[1ACC=%s, TE=%ld, SPEED=%s/s", lhm, t, ldhm);
			_l = l;
			sleep(1);
		}
	}
}

void tohuman(long inl, char* outstr)
{
    char* dc;
    double ddiff = (double) inl;
    dc = "B";
    if (ddiff >= 1024) {
        ddiff = ddiff / 1024;
        dc = "KiB";
    }
    if (ddiff >= 1024) {
        ddiff = ddiff / 1024;
        dc = "MiB";
    }
    if (ddiff >= 1024) {
		ddiff = ddiff / 1024;
		dc = "GiB";
	}
	sprintf(outstr, "%f%s", ddiff, dc);
}
