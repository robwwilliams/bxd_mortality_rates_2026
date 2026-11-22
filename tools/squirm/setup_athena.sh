#!/bin/bash
# Sets up Squirm, this project's guest runner, on ATHENA (tools/squirm/README.md). On ATHENA, in Terminal:
#   git clone https://github.com/robwwilliams/bxd_mortality_rates_2026.git ~/Code/squirm/bxd
#   bash ~/Code/squirm/bxd/tools/squirm/setup_athena.sh
# Safe to run again, and running it again is how Squirm picks up a new squirm.sh from main. It changes nothing outside
# ~/Code/squirm and its one launchd agent. It never installs or upgrades anything with Homebrew: Homebrew on ATHENA serves
# other work that depends on it staying exactly as it is.
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/Library/Frameworks/R.framework/Resources/bin:/usr/bin:/bin:/usr/sbin:/sbin"
SQ="$HOME/Code/squirm"; REPO="$SQ/bxd"; LABEL=com.robwilliams.squirm
NAME=$(scutil --get ComputerName 2>/dev/null || true)
[ "$NAME" = ATHENA ] || { echo "This Mac is named \"$NAME\". Squirm is set up for ATHENA only."; exit 1; }
if [ -e "$SQ/squirm.lock" ] && kill -0 "$(cat "$SQ/squirm.lock")" 2>/dev/null; then
  echo "A Squirm job is running ($(cat "$SQ/state.txt" 2>/dev/null)). Run this again when ~/Code/squirm/state.txt says idle."; exit 1
fi
command -v gh >/dev/null && gh auth status >/dev/null 2>&1 || { echo "GitHub's gh is missing or not signed in on ATHENA."; exit 1; }
git config --global --get-regexp '^credential\..*helper' 2>/dev/null | grep -q gh || gh auth setup-git
if ! command -v Rscript >/dev/null; then
  echo "R is not installed on ATHENA. Install R for Apple silicon from https://cran.r-project.org/bin/macosx/,"
  echo "the same version as on Metis (on Metis: R --version), then run this again. Squirm does not install R itself."; exit 1
fi
echo "== Squirm's clone of the repository, in $REPO"
mkdir -p "$SQ/Rlib" "$HOME/Library/LaunchAgents"
[ -d "$REPO/.git" ] || git clone -q https://github.com/robwwilliams/bxd_mortality_rates_2026.git "$REPO"
git -C "$REPO" fetch -q origin main && git -C "$REPO" checkout -q --detach origin/main
LOGIN=$(gh api user --jq .login); ID=$(gh api user --jq .id)
git -C "$REPO" config user.name "$LOGIN (ATHENA Squirm)"; git -C "$REPO" config user.email "$ID+$LOGIN@users.noreply.github.com"
echo "== the runner, copied from main"
cp "$REPO/tools/squirm/squirm.sh" "$SQ/squirm.sh"; bash -n "$SQ/squirm.sh"
echo "== the R packages installer.R names, into Squirm's own library ($SQ/Rlib)"
R_LIBS_USER="$SQ/Rlib" LC_ALL=C.UTF-8 Rscript "$REPO/installer.R" > "$SQ/Rlib/install.log" 2>&1 \
  && git -C "$REPO" hash-object installer.R > "$SQ/Rlib/.installer" || { echo "installer.R failed: see $SQ/Rlib/install.log"; exit 1; }
if [ ! -e "$SQ/done.txt" ]; then  # first setup only: Squirm takes only jobs pushed after it
  git -C "$REPO" fetch -q origin "+refs/heads/squirm/*:refs/remotes/origin/squirm/*"
  git -C "$REPO" for-each-ref --format='%(objectname) before-squirm %(refname:short)' refs/remotes/origin/squirm/ > "$SQ/done.txt"
fi
echo "== the launchd agent: every 5 minutes, at low I/O priority"
P="$HOME/Library/LaunchAgents/$LABEL.plist"
cat > "$P" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>/bin/bash</string><string>$SQ/squirm.sh</string></array>
  <key>StartInterval</key><integer>300</integer>
  <key>RunAtLoad</key><true/>
  <key>LowPriorityIO</key><true/>
  <key>StandardOutPath</key><string>$SQ/launchd.log</string><key>StandardErrorPath</key><string>$SQ/launchd.log</string>
</dict></plist>
PL
plutil -lint "$P" >/dev/null
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$P"
echo "== done. $(Rscript --version 2>&1 | head -1); $(sysctl -n hw.ncpu) cores, $(( $(sysctl -n hw.memsize) / 1073741824 )) GB"
echo "   What Squirm is doing:   cat ~/Code/squirm/state.txt     (its history: tail ~/Code/squirm/squirm.log)"
echo "   Hold everything:        touch ~/Code/squirm/HOLD        (release: rm ~/Code/squirm/HOLD)"
echo "   Stop it for good:       launchctl bootout gui/$(id -u)/$LABEL"
