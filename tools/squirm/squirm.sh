#!/bin/bash
# Squirm: the BXD project's guest runner on ATHENA (tools/squirm/README.md). ATHENA's own work comes first. Squirm starts
# a job only when the machine is otherwise idle, pauses it (SIGSTOP) whenever anything else needs the cores, and resumes it
# (SIGCONT) once ATHENA has been quiet for about a minute. launchd runs a copy of this script every 5 minutes; it runs at
# most one job at a time. A job is a branch squirm/<name> whose tip is a commit "Squirm job: ..." adding or changing
# exactly one squirm_jobs/<name>.sh. The results go back to the same branch as a commit "Squirm results: ...".
# Runs under macOS's /bin/bash 3.2: no bash 4 features.
set -uo pipefail
SQ="${SQUIRM_HOME:-$HOME/Code/squirm}"
REPO="$SQ/bxd"                                   # Squirm's own clone; nothing else on ATHENA is read or written
DONE="$SQ/done.txt"; LOG="$SQ/squirm.log"; STATE="$SQ/state.txt"; LOCK="$SQ/squirm.lock"; HOLD="$SQ/HOLD"
MAX_CORES="${SQUIRM_MAX_CORES:-12}"              # of ATHENA's 18
BUSY="${SQUIRM_BUSY:-2}"                         # other processes running, on average, that make Squirm step aside
QUIET="${SQUIRM_QUIET:-1}"                       # below this, Squirm may start or resume
POLL="${SQUIRM_POLL:-20}"                        # seconds between checks while a job runs
MAX_RUN_HOURS="${SQUIRM_MAX_RUN_HOURS:-48}"      # running time, pauses not counted
MAX_WALL_DAYS="${SQUIRM_MAX_WALL_DAYS:-7}"       # from start to end, pauses counted
MIN_FREE_MEM="${SQUIRM_MIN_FREE_MEM:-30}"        # percent of memory free (macOS's memory_pressure) needed to start
export PATH="${SQUIRM_PATH:-/opt/homebrew/bin:/usr/local/bin:/Library/Frameworks/R.framework/Resources/bin:/usr/bin:/bin:/usr/sbin:/sbin}"
mkdir -p "$SQ"; touch "$DONE"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"; }
state() { echo "$(date '+%Y-%m-%d %H:%M:%S') $*" > "$STATE"; }
gt() { awk -v x="$1" -v y="$2" 'BEGIN { exit !(x > y) }'; }
lt() { awk -v x="$1" -v y="$2" 'BEGIN { exit !(x < y) }'; }
if [ -e "$LOCK" ] && kill -0 "$(cat "$LOCK")" 2>/dev/null; then exit 0; fi
echo $$ > "$LOCK"; trap 'rm -f "$LOCK"' EXIT
if [ -e "$HOLD" ]; then state "held: $HOLD exists"; exit 0; fi
MYPG=$(ps -o pgid= -p $$ | tr -d ' ')
others() {  # the mean number of running processes outside Squirm and its job, over 5 samples a second apart
  local job="${1:-none}" i n=0 c
  for i in 1 2 3 4 5; do
    c=$(ps -A -o pgid=,stat= | awk -v a="$MYPG" -v b="$job" '$1 != a && $1 != b && $1 > 1 && $2 ~ /^R/ { c++ } END { print c + 0 }')
    n=$(( n + c )); sleep 1
  done
  awk -v n="$n" 'BEGIN { printf "%.1f", n / 5 }'
}
mem_free() {
  if command -v memory_pressure >/dev/null 2>&1; then
    memory_pressure 2>/dev/null | awk -F': ' '/free percentage/ { gsub("%", "", $2); print $2 + 0; f = 1 } END { if (!f) print 100 }'
  else echo 100; fi
}
[ -d "$REPO/.git" ] || { log "no clone at $REPO: run tools/squirm/setup_athena.sh"; exit 1; }
cd "$REPO" || exit 1
git fetch -q --prune origin "+refs/heads/squirm/*:refs/remotes/origin/squirm/*" 2>> "$LOG" || { state "GitHub unreachable"; exit 0; }
sha=""; branch=""; script=""
for line in $(git for-each-ref --sort=committerdate --format='%(objectname):%(refname:short)' refs/remotes/origin/squirm/); do
  s=${line%%:*}; b=${line#*:}; b=${b#origin/}
  grep -q "^$s " "$DONE" && continue
  case "$(git log -1 --format=%s "$s")" in
    "Squirm job"*) ;;
    *) echo "$s not-a-job $b" >> "$DONE"; continue ;;
  esac
  f=$(git diff-tree --no-commit-id --name-only -r "$s" | grep -E '^squirm_jobs/[^/]+\.sh$')
  if [ "$(printf '%s\n' "$f" | grep -c .)" != 1 ]; then
    echo "$s refused-not-one-script $b" >> "$DONE"; log "refused $b ($s): its tip must add or change exactly one squirm_jobs/*.sh"; continue
  fi
  sha=$s; branch=$b; script=$f; break
done
if [ -z "$sha" ]; then state "idle: no job waiting"; exit 0; fi
name=$(basename "$script" .sh)
o=$(others)
if ! lt "$o" "$QUIET"; then state "waiting to start $branch: ATHENA is busy ($o other processes running)"; exit 0; fi
m=$(mem_free)
if lt "$m" "$MIN_FREE_MEM"; then state "waiting to start $branch: $m% of memory free"; exit 0; fi
git checkout -q --detach "$sha" && git clean -qfdx -e data/local || { log "checkout of $sha failed"; exit 1; }
cores=$(grep -m1 -iE '^# *Cores:' "$script" | grep -oE '[0-9]+' | head -1); cores=${cores:-1}
[ "$cores" -gt "$MAX_CORES" ] && cores=$MAX_CORES; [ "$cores" -lt 1 ] && cores=1
OUT="output/squirm/$name"; mkdir -p "$OUT" "$SQ/Rlib"
if [ -f installer.R ] && command -v Rscript >/dev/null 2>&1; then  # the packages installer.R names, into Squirm's own library
  h=$(git hash-object installer.R)
  if [ "$h" != "$(cat "$SQ/Rlib/.installer" 2>/dev/null)" ]; then
    R_LIBS_USER="$SQ/Rlib" LC_ALL=C.UTF-8 Rscript installer.R >> "$SQ/Rlib/install.log" 2>&1 && echo "$h" > "$SQ/Rlib/.installer"
  fi
fi
echo "$sha started $branch" >> "$DONE"; log "started $branch ($sha) on $cores cores"
t0=$(date +%s)
( export SQUIRM_CORES="$cores" SQUIRM_OUT="$OUT" SQUIRM_NAME="$name" R_LIBS_USER="$SQ/Rlib" LC_ALL=C.UTF-8 \
         OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1
  exec nice -n 10 perl -e 'setpgrp(0, 0); exec @ARGV or die "squirm: cannot run the job: $!\n"' bash "$script" ) > "$OUT/squirm_log.txt" 2>&1 &
pid=$!                                           # the job's process group has the same number
command -v caffeinate >/dev/null 2>&1 && caffeinate -i -w "$pid" &
paused=0; pauses=0; busy_n=0; quiet_n=0; ran=0; last=$t0; why=""
state "running $branch"
while kill -0 "$pid" 2>/dev/null; do
  sleep "$POLL"
  now=$(date +%s); [ "$paused" = 0 ] && ran=$(( ran + now - last )); last=$now
  kill -0 "$pid" 2>/dev/null || break
  o=$(others "$pid")
  if [ "$paused" = 0 ]; then
    if [ -e "$HOLD" ] || gt "$o" "$BUSY"; then busy_n=$(( busy_n + 1 )); else busy_n=0; fi
    if [ -e "$HOLD" ] || [ "$busy_n" -ge 2 ]; then
      kill -STOP -"$pid" 2>/dev/null; paused=1; pauses=$(( pauses + 1 )); quiet_n=0
      log "paused $branch ($o other processes running$([ -e "$HOLD" ] && echo ', held'))"; state "paused $branch: ATHENA is busy"
    fi
  else
    if [ ! -e "$HOLD" ] && lt "$o" "$QUIET"; then quiet_n=$(( quiet_n + 1 )); else quiet_n=0; fi
    if [ "$quiet_n" -ge 3 ]; then
      kill -CONT -"$pid" 2>/dev/null; paused=0; busy_n=0; log "resumed $branch"; state "running $branch"
    fi
  fi
  if [ "$ran" -gt $(( MAX_RUN_HOURS * 3600 )) ] || [ $(( now - t0 )) -gt $(( MAX_WALL_DAYS * 86400 )) ]; then
    why=" (stopped at Squirm's limit: $MAX_RUN_HOURS hours running or $MAX_WALL_DAYS days in all)"
    kill -CONT -"$pid" 2>/dev/null; kill -TERM -"$pid" 2>/dev/null; sleep 10; kill -KILL -"$pid" 2>/dev/null; break
  fi
done
wait "$pid"; rc=$?
end=$(date +%s); [ "$paused" = 0 ] && ran=$(( ran + end - last ))
mkdir -p "$SQ/kept/$name"
big=$(find "$OUT" -type f -size +95M 2>/dev/null)
for f in $big; do mv "$f" "$SQ/kept/$name/"; done  # GitHub refuses files over 100 MB; these stay on ATHENA
{ echo "job: $name"; echo "branch: $branch"; echo "commit: $sha"; echo "exit: $rc$why"
  echo "cores: $cores"; echo "running: $ran s"; echo "start to end: $(( end - t0 )) s"; echo "pauses: $pauses"
  echo "machine: $(scutil --get ComputerName 2>/dev/null || hostname -s), $(sysctl -n machdep.cpu.brand_string 2>/dev/null || uname -m), $(sysctl -n hw.ncpu 2>/dev/null || nproc) cores, $(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1073741824 )) GB, macOS $(sw_vers -productVersion 2>/dev/null || echo none)"
  echo "R: $(command -v Rscript >/dev/null 2>&1 && Rscript --version 2>&1 | head -1 || echo none)"
  [ -n "$big" ] && echo "kept on ATHENA, over 95 MB: $(echo $big | tr ' ' '\n' | xargs -n1 basename | tr '\n' ' ')"
} > "$OUT/squirm_run.txt"
git add -f -- "$OUT"
git commit -q -m "Squirm results: $name (exit $rc; $(( ran / 60 )) min running on $cores cores; paused $pauses times)" || log "nothing to commit for $branch"
if git push -q origin "HEAD:refs/heads/$branch" 2>> "$LOG"; then st=finished
elif git push -q origin "HEAD:refs/heads/$branch-results" 2>> "$LOG"; then st="finished-on-$branch-results"
else st=push-failed; fi
echo "$sha $st $branch exit $rc" >> "$DONE"; log "$st $branch: exit $rc, $ran s running, $pauses pauses"; state "idle: last job $branch $st"
