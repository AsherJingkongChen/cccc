#define _GNU_SOURCE
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/wait.h>
#include <unistd.h>

static const char *hide_null[] = {
    "/home/agent/.claude.json",
    "/home/agent/.claude/.credentials.json",
    "/home/agent/.claude/CLAUDE.md",
    "/home/agent/.claude/channels/discord/.env",
    "/home/agent/.claude/channels/discord/access.json",
    "/home/agent/.claude/history.jsonl",
    "/home/agent/.claude/settings.json",
    "/home/agent/.claude/settings.local.json",
    "/home/agent/.entrypoint.sh",
    NULL,
};

static const char *hide_tmpfs[] = {
    "/home/agent/.claude/.litellm",
    "/home/agent/.claude/hooks",
    "/home/agent/.claude/scripts",
    NULL,
};

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: sandbox-lite CMD [ARGS...]\n"); return 1; }

    if (unshare(CLONE_NEWNS | CLONE_NEWPID) != 0) { perror("unshare"); return 1; }

    pid_t pid = fork();
    if (pid < 0) { perror("fork"); return 1; }
    if (pid > 0) {
        int status;
        waitpid(pid, &status, 0);
        return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
    }

    mount(NULL, "/", NULL, MS_PRIVATE | MS_REC, NULL);
    if (mount("proc", "/proc", "proc", MS_NOSUID | MS_NODEV, NULL) != 0)
        { perror("mount /proc"); return 1; }

    for (const char **p = hide_null; *p; p++)
        if (mount("/dev/null", *p, NULL, MS_BIND, NULL) != 0)
            { perror(*p); return 1; }
    for (const char **p = hide_tmpfs; *p; p++)
        if (mount("tmpfs", *p, "tmpfs", 0, "size=1k") != 0)
            { perror(*p); return 1; }

    setenv("LD_PRELOAD", "/usr/local/lib/sandbox-lite-port-ban.so", 1);

    if (setgid(getgid()) != 0) { perror("setgid"); return 1; }
    if (setuid(getuid()) != 0) { perror("setuid"); return 1; }

    execvp(argv[1], argv + 1);
    perror("exec");
    return 1;
}
