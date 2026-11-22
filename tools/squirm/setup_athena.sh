#!/bin/bash
# Sets up Squirm, this project's guest runner, on ATHENA (tools/squirm/README.md, "For Rob"). Rob runs it on ATHENA:
#   git clone https://github.com/robwwilliams/bxd_mortality_rates_2026.git /tmp/squirm-setup
#   sudo bash /tmp/squirm-setup/tools/squirm/setup_athena.sh
# Before it: a Standard macOS user "squirm", and a fine-grained GitHub token for this repository alone (README.md).
# It checks each layer that keeps a guest job in its place, and stops, changing nothing more, at the first that fails:
#   1. the user squirm can't enter Rob's home;
#   2. the token reaches no private repository, and can push to this one;
#   3. macOS's sandbox keeps a job off the network and out of everything under /Users but Squirm's clone and library.
# It never installs or upgrades anything with Homebrew, and changes nothing in Rob's own folders. Safe to run again; running
# it again is also how Squirm picks up a new squirm.sh.
set -euo pipefail
export PATH="/usr/local/bin:/Library/Frameworks/R.framework/Resources/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
R0="${SQUIRM_TEST_ROOT:-}"                              # tests only: a scratch root in place of /
U=squirm; UH="$R0/Users/$U"; SQ="$UH/squirm"; CTL="$R0/Users/Shared/squirm"; LIB="$R0/Library/Squirm"
LABEL=com.robwilliams.squirm; PLIST="$R0/Library/LaunchDaemons/$LABEL.plist"
SRC="$(cd "$(dirname "$0")" && pwd)"; REPO_URL=https://github.com/robwwilliams/bxd_mortality_rates_2026.git
[ -n "$R0" ] && REPO_URL="${SQUIRM_TEST_REPO:-$REPO_URL}"           # tests only
stop() { echo; echo "Stopped: $*"; echo "Nothing more was changed. Put that right and run this again."; exit 1; }
as_u() { sudo -u "$U" -H "$@"; }
[ "$(id -u)" = 0 ] || stop "run it with sudo:  sudo bash $0"
OWNER="${SUDO_USER:-}"; { [ -n "$OWNER" ] && [ "$OWNER" != root ]; } || stop "run it with sudo from your own account"
OH="$R0$(dscl . -read "/Users/$OWNER" NFSHomeDirectory | awk '{ print $2 }')"
[ "$(scutil --get ComputerName 2>/dev/null)" = ATHENA ] || stop "this Mac isn't named ATHENA"
id "$U" >/dev/null 2>&1 || stop "there is no user \"$U\". In System Settings, Users & Groups, add a Standard user whose account name is $U (any password: nobody logs in as it)"
if dseditgroup -o checkmember -m "$U" admin >/dev/null 2>&1; then stop "the user $U is an administrator: make it a Standard user"; fi
if [ -e "$CTL/status/squirm.lock" ] && kill -0 "$(cat "$CTL/status/squirm.lock")" 2>/dev/null; then
  stop "a Squirm job is running: run this again when $CTL/status/state.txt says idle"
fi
command -v sandbox-exec >/dev/null 2>&1 || stop "macOS's sandbox-exec is missing, so a job can't be fenced in"
command -v Rscript >/dev/null 2>&1 || stop "R isn't installed. Install R for Apple silicon from https://cran.r-project.org/bin/macosx/, the same version as on Metis (there: R --version). Squirm doesn't install R itself"

echo "== 1. The user $U can't enter $OH"
if as_u ls "$OH" >/dev/null 2>&1; then stop "the user $U can open $OH. Run   chmod 700 $OH   (you, and an administrator with sudo, can still open it)"; fi

echo "== 2. A token for this repository alone"
TOKEN=""
[ -s "$UH/.git-credentials" ] && TOKEN=$(sed -n 's|^https://squirm:\(.*\)@github\.com$|\1|p' "$UH/.git-credentials")
if [ -z "$TOKEN" ]; then read -rs -p "Paste the fine-grained token (it won't show): " TOKEN; echo; fi
[ -n "$TOKEN" ] || stop "no token"
priv=$(curl -s -m 20 -H "Authorization: Bearer $TOKEN" "https://api.github.com/user/repos?visibility=private&per_page=1" | tr -d ' \n\r')
case "$priv" in
  "[]") ;;
  *'"private":true'*) stop "the token can reach a private repository. Make a fine-grained token with only bxd_mortality_rates_2026 selected" ;;
  *) stop "GitHub didn't accept the token ($(printf '%s' "$priv" | head -c 120))" ;;
esac
( umask 077; printf 'https://squirm:%s@github.com\n' "$TOKEN" > "$UH/.git-credentials" ); chown "$U" "$UH/.git-credentials"; chmod 600 "$UH/.git-credentials"
unset TOKEN
as_u git config --global credential.helper store
as_u git config --global core.hooksPath /dev/null

echo "== Squirm's folders and its clone"
mkdir -p "$SQ" "$CTL/status" "$LIB" "$(dirname "$PLIST")"
chown "$U" "$SQ"; chmod 700 "$SQ"
chown "$OWNER" "$CTL"; chmod 755 "$CTL"                 # yours: HOLD goes here, and squirm can't remove it
chown "$U" "$CTL/status"; chmod 755 "$CTL/status"       # squirm's: what it is doing, readable by anyone on ATHENA
[ -d "$SQ/bxd/.git" ] || as_u git clone -q "$REPO_URL" "$SQ/bxd"
as_u git -C "$SQ/bxd" fetch -q origin main
as_u git -C "$SQ/bxd" checkout -q --detach -f origin/main
as_u git -C "$SQ/bxd" config user.name "Squirm (ATHENA)"
as_u git -C "$SQ/bxd" config user.email "squirm@athena.invalid"
as_u git -C "$SQ/bxd" push --dry-run -q origin HEAD:refs/heads/squirm-setup-check >/dev/null 2>&1 \
  || stop "the token can't push to this repository: give it Contents, read and write"
as_u mkdir -p "$SQ/Rlib" "$SQ/bxd/.squirm_home"

echo "== The runner and its two sandbox profiles, root's own, in $LIB"
cp "$SRC/squirm.sh" "$LIB/squirm.sh"; chown root:wheel "$LIB/squirm.sh"; chmod 755 "$LIB/squirm.sh"
for p in job install; do
  sed -e "s|@SQ@|$SQ|g" -e "s|@UH@|$UH|g" "$SRC/$p.sb" > "$LIB/$p.sb"; chown root:wheel "$LIB/$p.sb"; chmod 644 "$LIB/$p.sb"
done

echo "== 3. The sandbox holds: a probe runs as $U inside a job's sandbox"
got=$(as_u env HOME="$SQ/bxd/.squirm_home" sandbox-exec -f "$LIB/job.sb" /bin/bash -c '
  S=$0; O=$1; H=$2                                      # the folder of Squirm, your home, the home of squirm
  t() { if eval "$2" >/dev/null 2>&1; then echo "$1=yes"; else echo "$1=no"; fi; }
  t read_clone  "cat \"$S/bxd/README.md\""
  t write_clone "mkdir -p \"$S/bxd/output\" && echo x > \"$S/bxd/output/.squirm_probe\""
  t write_git   "echo x > \"$S/bxd/.git/squirm_probe\""
  t open_owner  "ls \"$O\""
  t read_token  "cat \"$H/.git-credentials\""
  t open_shared "ls /Users/Shared"
  t write_home  "echo x > \"$H/squirm_probe\""
  t network     "curl -s -m 5 -o /dev/null https://github.com"
  t r_runs      "Rscript --vanilla -e \"cat(1)\""
' "$SQ" "$OH" "$UH" | tr '\n' ' ')
want="read_clone=yes write_clone=yes write_git=no open_owner=no read_token=no open_shared=no write_home=no network=no r_runs=yes "
rm -f "$SQ/bxd/output/.squirm_probe"
[ "$got" = "$want" ] || stop "the sandbox didn't hold as it should. Wanted: $want  Got: $got"
echo "   $got"

echo "== R's packages (installer.R), into Squirm's own library"
as_u env HOME="$SQ/bxd/.squirm_home" R_LIBS_USER="$SQ/Rlib" LC_ALL=C.UTF-8 sandbox-exec -f "$LIB/install.sb" \
  Rscript --vanilla "$SQ/bxd/installer.R" > "$CTL/status/install.log" 2>&1 || stop "installer.R failed: see $CTL/status/install.log"
as_u sh -c "git -C '$SQ/bxd' hash-object installer.R > '$SQ/Rlib/.installer'"
if [ ! -e "$CTL/status/done.txt" ]; then                # first setup only: Squirm takes only jobs pushed after it
  as_u git -C "$SQ/bxd" fetch -q origin "+refs/heads/squirm/*:refs/remotes/origin/squirm/*"
  as_u sh -c "git -C '$SQ/bxd' for-each-ref --format='%(objectname) before-squirm %(refname:short)' refs/remotes/origin/squirm/ > '$CTL/status/done.txt'"
fi

echo "== The LaunchDaemon: every 5 minutes, as $U, at low I/O priority"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>UserName</key><string>$U</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$LIB/squirm.sh</string></array>
  <key>EnvironmentVariables</key><dict><key>HOME</key><string>$UH</string></dict>
  <key>StartInterval</key><integer>300</integer>
  <key>RunAtLoad</key><true/>
  <key>LowPriorityIO</key><true/>
  <key>StandardOutPath</key><string>$CTL/status/launchd.log</string><key>StandardErrorPath</key><string>$CTL/status/launchd.log</string>
</dict></plist>
PL
chown root:wheel "$PLIST"; chmod 644 "$PLIST"; plutil -lint "$PLIST" >/dev/null
launchctl bootout "system/$LABEL" 2>/dev/null || true
launchctl bootstrap system "$PLIST"
echo "== Done. $(Rscript --version 2>&1 | head -1); $(sysctl -n hw.ncpu) cores, $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
echo "   What Squirm is doing:   cat $CTL/status/state.txt      (its history: tail $CTL/status/squirm.log)"
echo "   Hold everything:        touch $CTL/HOLD                 (release: rm $CTL/HOLD)"
echo "   Stop it for good:       sudo launchctl bootout system/$LABEL"
