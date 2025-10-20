#!/bin/sh
# enum_no_sudo_stdout.sh - Non-privileged Linux enumeration (prints to stdout only)
# Usage: ./enum_no_sudo_stdout.sh [--fast] [-h|--help]
# Defensive, read-only enumeration. POSIX sh compatible.

FAST=0
PROGNAME=$(basename "$0")

usage() {
  cat <<USAGE
Usage: $PROGNAME [--fast] [-h|--help]

--fast    : quicker checks (limits full-filesystem scans)
-h, --help: show this help
USAGE
  exit 0
}

# parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --fast) FAST=1; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1"; usage ;;
  esac
done

sep() {
  printf '\n%s\n\n' "================================================================="
}

hdr() {
  printf '%s\n' "---- $1 ----"
}

run_cmd() {
  # header: $1, rest are command and args
  hdr="$1"
  shift
  sep
  hdr "$hdr"
  # run command, capture output; always succeed (don't let error stop script)
  if [ $# -eq 0 ]; then
    printf '(no command)\n'
  else
    # show command line in a subtle way
    printf '$ %s\n' "$*"
    # execute
    "$@" 2>&1 || true
  fi
}

# start
printf '\nNon-privileged enumeration (stdout only) - started at: %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
sep

##########################
# 1) Identity & groups
##########################
run_cmd "Identity (whoami / id)" sh -c 'printf "whoami: "; command -v whoami >/dev/null 2>&1 && whoami || id -un; printf "\n"; id'
run_cmd "Groups & common privileged groups" sh -c 'printf "groups: "; groups 2>/dev/null || true; printf "\n"; getent group sudo wheel admin docker lxd adm 2>/dev/null || true'

##########################
# 2) SUID / SGID enumeration
##########################
if [ "$FAST" -eq 0 ]; then
  run_cmd "SUID files (may be slow - full filesystem)" sh -c 'find / -xdev -perm /4000 -type f -ls 2>/dev/null || echo "(no results or permission denied)"'
else
  run_cmd "SUID files (fast - common paths)" sh -c 'find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -type f -perm /4000 -ls 2>/dev/null || echo "(no results or permission denied)"'
fi

if [ "$FAST" -eq 0 ]; then
  run_cmd "SGID files (may be slow - full filesystem)" sh -c 'find / -xdev -perm /2000 -type f -ls 2>/dev/null || echo "(no results or permission denied)"'
else
  run_cmd "SGID files (fast - common paths)" sh -c 'find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -type f -perm /2000 -ls 2>/dev/null || echo "(no results or permission denied)"'
fi

##########################
# 3) File capabilities
##########################
if command -v getcap >/dev/null 2>&1; then
  if [ "$FAST" -eq 0 ]; then
    run_cmd "File capabilities (getcap -r /)" getcap -r / 2>/dev/null || echo "(getcap ran, no output or permission denied)"
  else
    run_cmd "File capabilities (fast - common dirs)" getcap /bin/* /usr/bin/* 2>/dev/null || echo "(getcap ran, no output or permission denied)"
  fi
else
  run_cmd "File capabilities" sh -c 'echo "getcap not found - skipping capability scan"'
fi

##########################
# 4) World-writable files & dirs
##########################
if [ "$FAST" -eq 0 ]; then
  run_cmd "World-writable directories (full rootfs - may be slow)" sh -c 'find / -xdev -type d -perm -0002 -ls 2>/dev/null || echo "(no results or permission denied)"'
  run_cmd "World-writable files (full rootfs - may be slow)" sh -c 'find / -xdev -type f -perm -0002 -ls 2>/dev/null || echo "(no results or permission denied)"'
else
  run_cmd "World-writable directories (fast)" sh -c 'find /tmp /var/tmp /var/www /home -maxdepth 3 -type d -perm -0002 -ls 2>/dev/null || echo "(no results or permission denied)"'
  run_cmd "World-writable files (fast)" sh -c 'find /tmp /var/tmp /var/www /home -maxdepth 3 -type f -perm -0002 -ls 2>/dev/null || echo "(no results or permission denied)"'
fi

##########################
# 5) Cron & scheduled tasks
##########################
run_cmd "Current user's crontab" crontab -l 2>/dev/null || true
run_cmd "System cron directories and files" sh -c 'ls -ld /etc/cron* /var/spool/cron* /var/spool/cron 2>/dev/null || echo "(not accessible or not present)"'
run_cmd "Systemd timers (if systemctl present)" sh -c 'command -v systemctl >/dev/null 2>&1 && systemctl list-timers --all 2>/dev/null || echo "systemctl not found or not permitted"'

##########################
# 6) systemd unit files
##########################
run_cmd "systemd unit directories (list files)" sh -c 'ls -l /etc/systemd/system /lib/systemd/system 2>/dev/null || echo "(not accessible or not present)"'

##########################
# 7) Mount options and nosuid/noexec
##########################
run_cmd "Mount table" sh -c 'mount | column -t 2>/dev/null || cat /proc/mounts 2>/dev/null || echo "(mount info unavailable)"'
run_cmd "Check /proc/mounts for nosuid/noexec/nodev" sh -c 'grep -E "nosuid|noexec|nodev" /proc/mounts 2>/dev/null || echo "(no nosuid/noexec/nodev entries found or inaccessible)"'

##########################
# 8) Docker / LXD socket and groups
##########################
run_cmd "Docker socket (/var/run/docker.sock)" ls -l /var/run/docker.sock 2>/dev/null || echo "(docker socket not present or not readable)"
run_cmd "Check for docker/lxd group membership" sh -c 'groups | grep -E "docker|lxd" 2>/dev/null || echo "not in docker/lxd groups (or groups command not available)"'

##########################
# 9) Polkit / pkexec checks
##########################
#do it later too
##########################
# 10) Grep Possible Secrets
##########################

# do it later


##########################
# 11) Unix sockets & local services
##########################
if command -v ss >/dev/null 2>&1; then
  run_cmd "Unix sockets (ss -xl)" ss -xl 2>/dev/null || echo "(ss ran but no output or permission denied)"
else
  run_cmd "Socket files in /run & /tmp" sh -c 'ls -l /run/*.sock 2>/dev/null || ls -l /tmp/*.sock 2>/dev/null || echo "(no sockets found or not readable)"'
fi

##########################
# 12) Processes & listening ports
##########################
run_cmd "Top processes (ps aux head)" sh -c 'ps aux 2>/dev/null | head -n 200 || echo "(ps not available or permission denied)"'
if command -v ss >/dev/null 2>&1; then
  run_cmd "Listening sockets (ss -tulpen)" ss -tulpen 2>/dev/null || echo "(ss ran but no output or permission denied)"
elif command -v netstat >/dev/null 2>&1; then
  run_cmd "Listening sockets (netstat -tulpen)" netstat -tulpen 2>/dev/null || echo "(netstat ran but no output or permission denied)"
else
  run_cmd "Listening sockets" sh -c 'echo "ss/netstat not available - cannot list listening sockets"'
fi

##########################
# 13) Readable system config snippets (defensive)
##########################
run_cmd "Readable /etc/sudoers & snippets (may be unreadable)" sh -c 'ls -l /etc/sudoers* /etc/sudoers.d 2>/dev/null || echo "(not readable or not present)"; grep -R "NOPASSWD" /etc/sudoers* /etc/sudoers.d 2>/dev/null || true'
run_cmd "Readable /etc/passwd & /etc/group (sanity)" sh -c 'ls -l /etc/passwd /etc/group 2>/dev/null || true; awk -F: "{print \$1\":\"\$3\":\"\$4}" /etc/passwd 2>/dev/null | sed -n "1,200p" || true'

##########################
# 14) Kernel & distro info
##########################
run_cmd "Kernel & OS info" sh -c 'uname -a 2>/dev/null || true; [ -f /etc/os-release ] && sed -n "1,120p" /etc/os-release 2>/dev/null || true'

##########################
# 15) Helpful misc checks (namei)
##########################
for BIN in pkexec mount sudo; do
  if command -v "$BIN" >/dev/null 2>&1; then
    if command -v namei >/dev/null 2>&1; then
      run_cmd "Path permissions for $(command -v $BIN)" namei -l "$(command -v $BIN)" 2>/dev/null || true
    else
      run_cmd "Path permissions helper" sh -c 'echo "namei not available - skipping path component perms"'
    fi
  fi
done

##########################
# 16) Optional deep scans (only when not FAST)
##########################
if [ "$FAST" -eq 0 ]; then
  run_cmd "Quick find for leftover backups /.git /db dumps (may be slow)" sh -c 'find / -xdev -type f \( -iname "*.bak" -o -iname "*backup*" -o -iname "*.sql" -o -iname "*.sql.gz" -o -iname "*.tar.gz" -o -iname ".git" \) -ls 2>/dev/null | sed -n "1,200p" || echo "(no results or permission denied)"'
fi

# finish
sep
printf 'Enumeration finished at: %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
sep
printf 'Notes:\n - This script is read-only and non-destructive.\n - Use --fast to avoid full-filesystem scans.\n - Review highlighted items manually (SUID, docker sock, writable cron scripts, keys, etc.).\n\n'
exit 0
