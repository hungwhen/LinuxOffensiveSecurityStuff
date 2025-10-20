#!/bin/sh
# usage: ./check-bins.sh [--sudo] [--legend]
# Prints only FOUND binaries with aligned columns:
# NAME | PATH | STATUS | SUDO | SUID | CAPS
# POSIX-compatible. Requires awk.

USE_SUDO=0
SHOW_LEGEND=0
for arg in "$@"; do
  case "$arg" in
    --sudo)   USE_SUDO=1 ;;
    --legend) SHOW_LEGEND=1 ;;
  esac
done

# --- compact list of binaries (edit as needed) ---
set -- 7z aa-exec ab agetty alpine ansible-playbook ansible-test aoss apache2ctl apt-get apt ar aria2c arj arp as ascii-xfr ascii85 ash aspell at atobm awk aws base32 base58 base64 basenc basez bash batcat bc bconsole bpftrace bridge bundle bundler busctl busybox byebug bzip2 c89 c99 cabal cancel capsh cat cdist certbot check_by_ssh check_cups check_log check_memory check_raid check_ssl_cert check_statusfile chmod choom chown chroot clamscan cmp cobc column comm composer cowsay cowthink cp cpan cpio cpulimit crash crontab csh csplit csvtool cupsfilter curl cut dash date dc dd debugfs dialog diff dig distcc dmesg dmidecode dmsetup dnf docker dos2unix dosbox dotnet dpkg dstat dvips easy_install eb ed efax elvish emacs enscript env eqn espeak ex exiftool expand expect facter file find finger fish flock fmt fold fping ftp gawk gcc gcloud gcore gdb gem genie genisoimage ghc ghci gimp ginsh git grc grep gtester gzip hd head hexdump highlight hping3 iconv iftop install ionice ip irb ispell jjs joe join journalctl jq jrunscript jtag julia knife ksh ksshell ksu kubectl latex latexmk ld.so ldconfig less lftp links ln loginctl logsave look lp ltrace lua lualatex luatex lwp-download lwp-request mail make man mawk minicom more mosquitto mount msfconsole msgattrib msgcat msgconv msgfilter msgmerge msguniq mtr multitime mv mysql nano nasm nawk nc ncdu ncftp neofetch nft nice nl nm nmap node nohup npm nroff nsenter ntpdate octave od openssl openvpn openvt opkg pandoc paste pax pdb pdflatex pdftex perf perl perlbug pexec pg php pic pico pidstat pip pkexec pkg posh pr pry psftp psql ptx puppet pwsh python rake rc readelf red redcarpet redis restic rev rlogin rlwrap rpm rpmdb rpmquery rpmverify rsync rtorrent ruby run-mailcap run-parts runscript rview rvim sash scanmem scp screen script scrot sed service setarch setfacl setlock shuf slsh smbclient snap socat socket soelim softlimit sort split sqlite3 sqlmap ss ssh-agent ssh-keygen ssh-keyscan ssh sshpass start-stop-daemon stdbuf strace strings su sudo sysctl systemctl systemd-resolve tac tail tar task taskset tasksh tbl tclsh tcpdump tdbtool tee telnet terraform tex time timedatectl timeout tmate tmux top torify torsocks troff tshark ul unexpand uniq unshare unsquashfs unzip update-alternatives uudecode uuencode vagrant valgrind varnishncsa vi view vigr vim vimdiff vipw virsh volatility w3m wall watch wc wget whiptail whois wireshark wish xargs xdg-user-dir xdotool xelatex xmodmap xmore xpad xxd xz yarn yash yelp yum zathura zip zsh zsoelim zypper

# --- temp files ---
TMP=$(mktemp -t binchk.XXXXXX 2>/dev/null || echo "/tmp/binchk.$$")
TMPMAP=$(mktemp -t binmap.XXXXXX 2>/dev/null || echo "/tmp/binmap.$$")
: > "$TMP" || { echo "Cannot write temp file: $TMP" >&2; exit 1; }
: > "$TMPMAP" || { echo "Cannot write temp file: $TMPMAP" >&2; rm -f "$TMP"; exit 1; }

# --- SHORT MAPPING: binary|CAPS (already abbreviated) ---
# Legend codes:
#   SH = shell, RevSH = reverse shell, NI-RevSH = non-interactive reverse shell, NI-BindSH = non-interactive bind shell, BindSH = bind shell
#   F-R/W = file read/write, F-Up/Down = file upload/download, LibLd = library load, Cmd = command, SUID, L-SUID, Sudo
cat > "$TMPMAP" <<'MAP'
7z|F-R Sudo
aa-exec|SH SUID Sudo
ab|F-Up/Down SUID Sudo
agetty|SUID
alpine|F-R SUID Sudo
ansible-playbook|SH Sudo
ansible-test|SH Sudo
aoss|SH Sudo
apache2ctl|F-R Sudo
apt-get|SH Sudo
apt|SH Sudo
ar|F-R SUID Sudo
aria2c|Cmd F-Down Sudo L-SUID
arj|F-R/W SUID Sudo
arp|F-R SUID Sudo
as|F-R SUID Sudo
ascii-xfr|F-R SUID Sudo
ascii85|F-R Sudo
ash|SH F-W SUID Sudo
aspell|F-R SUID Sudo
at|SH Cmd Sudo
atobm|F-R SUID Sudo
awk|SH NI-RevSH NI-BindSH F-R/W SUID Sudo L-SUID
aws|SH Sudo
base32|F-R SUID Sudo
base58|F-R Sudo
base64|F-R SUID Sudo
basenc|F-R SUID Sudo
basez|F-R SUID Sudo
bash|SH RevSH F-Up/Down F-R/W LibLd SUID Sudo
batcat|SH Sudo L-SUID
bc|F-R SUID Sudo
bconsole|SH F-R Sudo
bpftrace|Sudo
bridge|F-R SUID Sudo
bundle|SH Sudo
bundler|SH Sudo
busctl|SH SUID Sudo
busybox|SH RevSH F-Up F-W F-R SUID Sudo
byebug|SH Sudo L-SUID
bzip2|F-R SUID Sudo
c89|SH F-R/W Sudo
c99|SH F-R/W Sudo
cabal|SH SUID Sudo
cancel|F-Up
capsh|SH SUID Sudo
cat|F-R SUID Sudo
cdist|SH Sudo
certbot|SH Sudo
check_by_ssh|SH Sudo
check_cups|F-R Sudo
check_log|F-R/W Sudo
check_memory|F-R Sudo
check_raid|F-R Sudo
check_ssl_cert|Cmd Sudo
check_statusfile|F-R Sudo
chmod|SUID Sudo
choom|SH SUID Sudo
chown|SUID Sudo
chroot|SUID Sudo
clamscan|F-R SUID Sudo
cmp|F-R SUID Sudo
cobc|SH Sudo
column|F-R SUID Sudo
comm|F-R SUID Sudo
composer|SH Sudo L-SUID
cowsay|SH Sudo
cowthink|SH Sudo
cp|F-R/W SUID Sudo
cpan|SH RevSH F-Up/Down Sudo
cpio|SH F-R/W SUID Sudo
cpulimit|SH SUID Sudo
crash|SH Cmd Sudo
crontab|Cmd Sudo
csh|SH F-W SUID Sudo
csplit|F-R/W SUID Sudo
csvtool|SH F-R/W SUID Sudo
cupsfilter|F-R SUID Sudo
curl|F-Up/Down F-R/W SUID Sudo
cut|F-R SUID Sudo
dash|SH F-W SUID Sudo
date|F-R SUID Sudo
dc|SH Sudo L-SUID
dd|F-R/W SUID Sudo
debugfs|SH SUID Sudo
dialog|F-R SUID Sudo
diff|F-R SUID Sudo
dig|F-R SUID Sudo
distcc|SH SUID Sudo
dmesg|SH F-R Sudo
dmidecode|Sudo
dmsetup|SUID Sudo
dnf|Sudo
docker|SH F-R/W SUID Sudo
dos2unix|F-W
dosbox|F-R/W SUID Sudo
dotnet|SH F-R Sudo
dpkg|SH Sudo
dstat|SH Sudo
dvips|SH Sudo L-SUID
easy_install|SH RevSH F-Up/Down F-R/W LibLd Sudo
eb|SH Sudo
ed|SH F-R/W SUID Sudo L-SUID
efax|SUID Sudo
elvish|SH F-R/W SUID Sudo
emacs|SH F-R/W SUID Sudo
enscript|SH Sudo
env|SH SUID Sudo
eqn|F-R SUID Sudo
espeak|F-R SUID Sudo
ex|SH F-R/W Sudo
exiftool|F-R/W Sudo
expand|F-R SUID Sudo
expect|SH F-R SUID Sudo
facter|SH Sudo
file|F-R SUID Sudo
find|SH F-W SUID Sudo
finger|F-Up/Down
fish|SH SUID Sudo
flock|SH SUID Sudo
fmt|F-R SUID Sudo
fold|F-R SUID Sudo
fping|F-R Sudo
ftp|SH F-Up/Down Sudo
gawk|SH NI-RevSH NI-BindSH F-R/W SUID Sudo L-SUID
gcc|SH F-R/W Sudo
gcloud|SH Sudo
gcore|F-R SUID Sudo
gdb|SH RevSH F-Up/Down F-R/W LibLd SUID Sudo
gem|SH Sudo
genie|SH SUID Sudo
genisoimage|F-R SUID Sudo
ghc|SH Sudo
ghci|SH Sudo
gimp|SH RevSH F-Up/Down F-R/W LibLd SUDO
ginsh|SH Sudo L-SUID
git|SH F-R/W Sudo L-SUID
grc|SH Sudo
grep|F-R SUID Sudo
gtester|SH F-W SUID Sudo
gzip|F-R SUID Sudo
hd|F-R SUID Sudo
head|F-R SUID Sudo
hexdump|F-R SUID Sudo
highlight|F-R SUID Sudo
hping3|SH SUID Sudo
iconv|F-R/W SUID Sudo
iftop|SH Sudo L-SUID
install|SUID Sudo
ionice|SH SUID Sudo
ip|F-R SUID Sudo
irb|SH RevSH F-Up/Down F-R/W LibLd Sudo
ispell|SH SUID Sudo
jjs|SH RevSH F-Down F-R/W SUID Sudo
joe|SH Sudo L-SUID
join|F-R SUID Sudo
journalctl|SH Sudo
jq|F-R SUID Sudo
jrunscript|SH RevSH F-Down F-R/W SUID Sudo
jtag|SH Sudo
julia|SH RevSH F-Down F-R/W SUID Sudo
knife|SH Sudo
ksh|SH RevSH BindSH F-Up/Down F-R/W SUID Sudo
ksshell|F-R SUID Sudo
ksu|Sudo
kubectl|F-Up SUID Sudo
latex|SH F-R Sudo L-SUID
latexmk|SH F-R Sudo
ld.so|SH SUID Sudo
ldconfig|Sudo L-SUID
less|SH F-R/W SUID Sudo
lftp|SH Sudo L-SUID
links|F-R SUID Sudo
ln|Sudo
loginctl|SH Sudo
logsave|SH SUID Sudo
look|F-R SUID Sudo
lp|F-Up
ltrace|SH F-R/W Sudo
lua|SH NI-RevSH NI-BindSH F-Up/Down F-R/W SUID Sudo L-SUID
lualatex|SH Sudo L-SUID
luatex|SH Sudo L-SUID
lwp-download|F-Down F-R/W Sudo
lwp-request|F-R Sudo
mail|SH Sudo
make|SH F-W SUID Sudo
man|SH F-R Sudo
mawk|SH F-R/W SUID Sudo L-SUID
minicom|SH SUID Sudo
more|SH F-R SUID Sudo
mosquitto|F-R SUID Sudo
mount|Sudo
msfconsole|SH Sudo
msgattrib|F-R SUID Sudo
msgcat|F-R SUID Sudo
msgconv|F-R SUID Sudo
msgfilter|SH F-R SUID Sudo
msgmerge|F-R SUID Sudo
msguniq|F-R SUID Sudo
mtr|F-R Sudo
multitime|SH SUID Sudo
mv|SUID Sudo
mysql|SH LibLd Sudo L-SUID
nano|SH F-R/W Sudo L-SUID
nasm|F-R SUID Sudo
nawk|SH NI-RevSH NI-BindSH F-R/W SUID Sudo L-SUID
nc|RevSH BindSH F-Up/Down Sudo L-SUID
ncdu|SH Sudo L-SUID
ncftp|SH SUID Sudo
neofetch|SH F-R Sudo
nft|F-R SUID Sudo
nice|SH SUID Sudo
nl|F-R SUID Sudo
nm|F-R SUID Sudo
nmap|SH NI-RevSH NI-BindSH F-Up/Down F-R/W SUID Sudo L-SUID
node|SH RevSH BindSH F-Up/Down F-R/W SUID Sudo
nohup|SH Cmd SUID Sudo
npm|SH Sudo
nroff|SH F-R Sudo
nsenter|SH Sudo
ntpdate|F-R SUID Sudo
octave|SH F-R/W Sudo L-SUID
od|F-R SUID Sudo
openssl|RevSH F-Up/Down F-R/W LibLd SUID Sudo
openvpn|SH F-R SUID Sudo
openvt|Sudo
opkg|Sudo
pandoc|SH F-R/W SUID Sudo L-SUID
paste|F-R SUID Sudo
pax|F-R
pdb|SH Sudo
pdflatex|SH F-R Sudo L-SUID
pdftex|SH Sudo L-SUID
perf|SH SUID Sudo
perl|SH RevSH F-R LibLd SUID Sudo
perlbug|SH Sudo
pexec|SH SUID Sudo
pg|SH F-R SUID Sudo
php|SH Cmd RevSH F-Up/Down F-R/W SUID Sudo
pic|SH F-R Sudo L-SUID
pico|SH F-R/W Sudo L-SUID
pidstat|Cmd SUID Sudo
pip|SH RevSH F-Up/Down F-R/W LibLd Sudo
pkexec|Sudo
pkg|Sudo
posh|SH Sudo L-SUID
pr|F-R SUID Sudo
pry|SH Sudo L-SUID
psftp|SH Sudo L-SUID
psql|SH Sudo
ptx|F-R SUID Sudo
puppet|SH F-R/W Sudo
pwsh|SH F-W Sudo
python|SH RevSH F-Up/Down F-R/W LibLd SUID Sudo
rake|SH F-R Sudo L-SUID
rc|SH SUID Sudo
readelf|F-R SUID Sudo
red|F-R/W Sudo
redcarpet|F-R Sudo
redis|F-W
restic|F-Up SUID Sudo
rev|F-R SUID Sudo
rlogin|F-Up
rlwrap|SH F-W SUID Sudo
rpm|SH Sudo L-SUID
rpmdb|SH Sudo L-SUID
rpmquery|SH Sudo L-SUID
rpmverify|SH Sudo L-SUID
rsync|SH SUID Sudo
rtorrent|SH SUID
ruby|SH RevSH F-Up/Down F-R/W LibLd Sudo
run-mailcap|SH F-R/W Sudo
run-parts|SH SUID Sudo
runscript|SH Sudo L-SUID
rview|SH RevSH NI-RevSH NI-BindSH F-Up/Down F-R/W LibLd SUID Sudo L-SUID
rvim|SH RevSH NI-RevSH NI-BindSH F-Up/Down F-R/W LibLd SUID Sudo L-SUID
sash|SH SUID Sudo
scanmem|SH SUID Sudo
scp|SH F-Up/Down Sudo L-SUID
screen|SH F-W Sudo
script|SH F-W Sudo
scrot|SH Sudo L-SUID
sed|SH Cmd F-R/W SUID Sudo
service|SH Sudo
setarch|SH SUID Sudo
setfacl|SUID Sudo
setlock|SH SUID Sudo
sftp|SH F-Up/Down Sudo
sg|SH Sudo
shuf|F-R/W SUID Sudo
slsh|SH Sudo L-SUID
smbclient|SH F-Up/Down Sudo
snap|Sudo
socat|SH RevSH BindSH F-Up/Down F-R/W Sudo L-SUID
socket|RevSH BindSH
soelim|F-R SUID Sudo
softlimit|SH SUID Sudo
sort|F-R SUID Sudo
split|SH Cmd F-R/W Sudo
sqlite3|SH F-R/W SUID Sudo L-SUID
sqlmap|SH Sudo
ss|F-R SUID Sudo
ssh-agent|SH SUID Sudo
ssh-keygen|LibLd SUID Sudo
ssh-keyscan|F-R SUID Sudo
ssh|SH F-Up/Down F-R Sudo
sshpass|SH SUID Sudo
start-stop-daemon|SH SUID Sudo
stdbuf|SH SUID Sudo
strace|SH F-W SUID Sudo
strings|F-R SUID Sudo
su|Sudo
sudo|Sudo
sysctl|Cmd F-R SUID Sudo
systemctl|SUID Sudo
systemd-resolve|Sudo
tac|F-R SUID Sudo
tail|F-R SUID Sudo
tar|SH F-Up/Down F-R/W Sudo L-SUID
task|SH Sudo
taskset|SH SUID Sudo
tasksh|SH Sudo L-SUID
tbl|F-R SUID Sudo
tclsh|SH NI-RevSH SUID Sudo
tcpdump|Cmd Sudo
tdbtool|SH Sudo L-SUID
tee|F-W SUID Sudo
telnet|SH RevSH Sudo L-SUID
terraform|F-R SUID Sudo
tex|SH Sudo L-SUID
tftp|F-Up/Down SUID Sudo
tic|F-R SUID Sudo
time|SH SUID Sudo
timedatectl|SH Sudo
timeout|SH SUID Sudo
tmate|SH Sudo L-SUID
tmux|SH F-R Sudo
top|SH Sudo
torify|SH Sudo
torsocks|SH Sudo
troff|F-R SUID Sudo
tshark|SH
ul|F-R SUID Sudo
unexpand|F-R SUID Sudo
uniq|F-R SUID Sudo
unshare|SH SUID Sudo
unsquashfs|SUID Sudo
unzip|SUID Sudo
update-alternatives|SUID Sudo
uudecode|F-R SUID Sudo
uuencode|F-R SUID Sudo
vagrant|SH SUID Sudo
valgrind|SH Sudo
varnishncsa|SUID Sudo
vi|SH F-R/W Sudo
view|SH RevSH NI-RevSH NI-BindSH F-Up/Down F-R/W LibLd SUID Sudo L-SUID
vigr|SUID Sudo
vim|SH RevSH NI-RevSH NI-BindSH F-Up/Down F-R/W LibLd SUID Sudo L-SUID
vimdiff|SH RevSH NI-RevSH NI-BindSH F-Up/Down F-R/W LibLd SUID Sudo L-SUID
vipw|SUID Sudo
virsh|F-R/W Sudo
volatility|SH
w3m|F-R SUID Sudo
wall|Sudo
watch|SH SUID Sudo L-SUID
wc|F-R SUID Sudo
wget|SH F-Up/Down F-R/W SUID Sudo
whiptail|F-R SUID Sudo
whois|F-Up/Down
wireshark|Cmd Sudo
wish|SH NI-RevSH Sudo
xargs|SH F-R SUID Sudo
xdg-user-dir|SH Sudo
xdotool|SH SUID Sudo
xelatex|SH F-R Sudo L-SUID
xetex|SH Sudo L-SUID
xmodmap|F-R SUID Sudo
xmore|F-R SUID Sudo
xpad|F-R Sudo
xxd|F-W/R SUID Sudo
xz|F-R SUID Sudo
yarn|SH Sudo
yash|SH SUID Sudo
yelp|F-R
yum|F-Down Sudo
zathura|SH Sudo
zip|SH F-R Sudo L-SUID
zsh|SH F-R/W SUID Sudo
zsoelim|F-R SUID Sudo
zypper|SH Sudo
MAP

# header row
printf 'NAME\tPATH\tSTATUS\tSUDO\tOWNER\tSUID\tCAPS\n' >> "$TMP"

# collect rows (found only)
for bin in "$@"; do
  command -v -- "$bin" >/dev/null 2>&1 || continue
  path=$(command -v -- "$bin" 2>/dev/null)
  status="found"
  suid="n/a"
  owner="n/a"

  if [ -n "$path" ] && [ -f "$path" ]; then
    [ -x "$path" ] && status="found+exec"
    if [ -u "$path" ]; then suid="yes"; else suid="no"; fi
    owner=$(ls -ld "$path" 2>/dev/null | awk '{print $3}')
  fi

  if [ "$USE_SUDO" -eq 1 ]; then
    target=${path:-$bin}
    if sudo -n -l "$target" >/dev/null 2>&1; then sudostatus="yes"; else sudostatus="no"; fi
  else
    sudostatus="n/a"
  fi

  cap=$(awk -F'|' -v b="$bin" '$1==b{print $2; exit}' "$TMPMAP")
  [ -z "$cap" ] && cap="n/a"

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$bin" "${path:-}" "$status" "$sudostatus" "$owner" "$suid" "$cap" >> "$TMP"
done

# pretty-print aligned columns
awk -F '\t' '
BEGIN { for(i=1;i<=7;i++) W[i]=0 }
{
  for(i=1;i<=7;i++) if (length($i)>W[i]) W[i]=length($i)
  L[NR]=$0
}
END {
  for(i=1;i<=6;i++) W[i]+=2
  for(n=1;n<=NR;n++){
    split(L[n],f,"\t")
    printf "%-*s%-*s%-*s%-*s%-*s%-*s%s\n", W[1],f[1], W[2],f[2], W[3],f[3], W[4],f[4], W[5],f[5], W[6],f[6], f[7]
  }
}
' "$TMP"

# optional legend
if [ "$SHOW_LEGEND" -eq 1 ]; then
  printf '\nLegend: SH=shell, RevSH=reverse shell, NI-RevSH=non-interactive reverse shell, NI-BindSH=non-interactive bind shell, BindSH=bind shell, F-R/W=file read/write, F-Up/Down=file upload/download, LibLd=library load, Cmd=command, SUID=setuid, L-SUID=limited suid, Sudo=sudo\n'
fi

# cleanup
rm -f "$TMP" "$TMPMAP"
