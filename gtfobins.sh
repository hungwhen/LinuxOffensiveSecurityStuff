#!/bin/sh
# usage: ./check-bins.sh [--sudo]
# Prints: NAME<TAB>PATH<TAB>STATUS<TAB>SUDO
# STATUS: missing | found | found+exec
# SUDO:   n/a | yes | no

USE_SUDO=0
[ "${1:-}" = "--sudo" ] && USE_SUDO=1

# --- compact list of binaries (single line) ---
set -- 7z aa-exec agetty alpine ansible-playbook ansible-test aoss apache2ctl apt-get apt ar aria2c arj arp as ascii-xfr ascii85 ash aspell at atobm awk aws base32 base58 base64 basenc basez bash batcat bc bconsole bpftrace bridge bundle bundler busctl busybox byebug bzip2 c89 c99 cabal cancel capsh cat cdist certbot check_by_ssh check_cups check_log check_memory check_raid check_ssl_cert check_statusfile chmod choom chown chroot clamscan cmp cobc column comm composer cowsay cowthink cp cpan cpio cpulimit crash crontab csh csplit csvtool cupsfilter curl cut dash date dc dd debugfs dialog diff dig distcc dmesg dmidecode dmsetup dnf docker dos2unix dosbox dotnet dpkg dstat dvips easy_install eb ed efax elvish emacs enscript env eqn espeak ex exiftool expand expect facter file find finger fish flock fmt fold fping ftp gawk gcc gcloud gcore gdb gem genie genisoimage ghc ghci gimp ginsh git grc grep gtester gzip hd head hexdump highlight hping3 iconv iftop install ionice ip irb ispell jjs joe join journalctl jq jrunscript jtag julia knife ksh ksshell ksu kubectl latex latexmk ld.so ldconfig less lftp links ln loginctl logsave look lp ltrace lua lualatex luatex lwp-download lwp-request mail make man mawk minicom more mosquitto mount msfconsole msgattrib msgcat msgconv msgfilter msgmerge msguniq mtr multitime mv mysql nano nasm nawk nc ncdu ncftp neofetch nft nice nl nm nmap node nohup npm nroff nsenter ntpdate octave od openssl openvpn openvt opkg pandoc paste pax pdb pdflatex pdftex perf perl perlbug pexec pg php pic pico pidstat pip pkexec pkg posh pr pry psftp psql ptx puppet pwsh python rake rc readelf red redcarpet redis restic rev rlogin rlwrap rpm rpmdb rpmquery rpmverify rsync rtorrent ruby run-mailcap run-parts runscript rview rvim sash scanmem scp screen script scrot sed service setarch setfacl setlock shuf slsh smbclient snap socat socket soelim softlimit sort split sqlite3 sqlmap ss ssh-agent ssh-keygen ssh-keyscan ssh sshpass start-stop-daemon stdbuf strace strings su sudo sysctl systemctl systemd-resolve tac tail tar task taskset tasksh tbl tclsh tcpdump tdbtool tee telnet terraform tex time timedatectl timeout tmate tmux top torify torsocks troff tshark ul unexpand uniq unshare unsquashfs unzip update-alternatives uudecode uuencode vagrant valgrind varnishncsa vi view vigr vim vimdiff vipw virsh volatility w3m wall watch wc wget whiptail whois wireshark wish xargs xdg-user-dir xdotool xelatex xmodmap xmore xpad xxd xz yarn yash yelp yum zathura zip zsh zsoelim zypper

# header
printf '%s\t%s\t%s\t%s\n' "NAME" "PATH" "STATUS" "SUDO"

# check each
for bin in "$@"; do
  # Find via POSIX command lookup
  if command -v -- "$bin" >/dev/null 2>&1; then
    path=$(command -v -- "$bin" 2>/dev/null)
    status="found"
    # If it's a regular file and executable, mark found+exec
    if [ -n "$path" ] && [ -f "$path" ] && [ -x "$path" ]; then
      status="found+exec"
    fi

    if [ "$USE_SUDO" -eq 1 ]; then
      # Prefer checking the full path if we have it; fall back to name
      target=${path:-$bin}
      if sudo -n -l "$target" >/dev/null 2>&1; then
        sudostatus="yes"
      else
        sudostatus="no"
      fi
    else
      sudostatus="n/a"
    fi

    printf '%s\t%s\t%s\t%s\n' "$bin" "${path:-}" "$status" "$sudostatus"
  else
    printf '%s\t%s\t%s\t%s\n' "$bin" "" "missing" "n/a"
  fi
done
