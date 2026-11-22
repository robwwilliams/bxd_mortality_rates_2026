# How to use ATHENA: Squirm

For Rob, and for every Claude session that works in this repository.

ATHENA is Rob's Mac Studio (Apple M5 Max, 18 cores). Its own work comes first. This project is a guest there: it fills the gaps when ATHENA would otherwise sit idle. Squirm is the small runner that makes that so. It isn't Slurm: it doesn't share the machine out by priority, it squirms out of the way.

## In short

- **You never log in to ATHENA.** From Metis, you push a job branch, `squirm/<name>`. Squirm, on ATHENA, runs the job when ATHENA is idle. It pushes the results back to the same branch.
- **Squirm waits and steps aside on its own.** It starts a job only when nothing else is running, and pauses it whenever anything else needs the machine. It resumes the job about a minute after ATHENA is quiet again. A pause loses nothing: the job simply stops where it is and continues later.
- **One job at a time,** in the order the branches were pushed.

## The rules for a guest

1. **ATHENA's own work always comes first.** That's the point of Squirm, and nothing in this project should work against it.
2. **Plan for waiting.** A job may wait hours or days before it starts, and pause many times once it has. Squirm is for work that can wait. Anything needed today runs on Metis.
3. **Don't get around it.**
   - Don't ask Rob to pause ATHENA's other work, to change Squirm's limits, or to run anything on ATHENA by hand.
   - Don't split one job into many to get more turns.
4. **Keep jobs modest:**
   - at most 12 cores (Squirm caps the count it gives a job);
   - **memory:** state the most memory the job will use, in its `# Memory:` line, at most 6 GB of ATHENA's 36. Squirm ends a job that goes more than 1 GB over what it stated.
   - **restartable:** while a job is paused, if ATHENA runs short of memory (under 20% free), Squirm ends the job, pushes nothing and starts it again from its commit later. It does this at most 3 times. So write jobs that can start over, and keep what's finished, as the permutation recipe below does.
   - no output file over 100 MB. GitHub refuses larger files, so Squirm keeps them on ATHENA and lists them in `squirm_run.txt`.
5. **A job stays inside its own space,** and ATHENA enforces it (see "How the guest is kept in its place" below):
   - It runs in Squirm's own clone of this repository, at the commit that added it, as the macOS user `squirm`, inside macOS's sandbox.
   - It can read only what that commit holds, and Squirm's R library. `data/local/` isn't on ATHENA.
   - It writes only under `$SQUIRM_OUT`. Squirm returns nothing else, and drops any symbolic or hard link a job leaves there.
   - It has no network and can't install anything. The R packages come from `installer.R`, which Squirm installs into its own library before the job starts.
6. **Leave the rest of ATHENA alone.**
   - Other folders on ATHENA belong to Rob's other projects, some of them private. A job can't reach them, and nothing here should try to, or name or describe anything about them. This repository is public.
   - Never change Homebrew, system settings or launchd jobs on ATHENA.
7. **Everything a job commits is public,** like the rest of this repository. No tokens and no data Rob hasn't released go into a job.
8. **Tell Rob only when Squirm itself seems broken:**
   - a short job that hasn't started after three days;
   - a job whose results show it never ran: a nonzero exit with an empty `squirm_log.txt`.
   One line is enough.

## What fits

- **Good on ATHENA:** CPU-bound R work that splits into chunks with fixed seeds:
  - permutation scans, such as R/qtl2's `scan1perm`;
  - bootstraps;
  - jackknives and permutations over strains;
  - sweeps over many definitions.
- **Not for Squirm:**
  - GeneNetwork (GN4AI) calls, which need the network and a token;
  - figures and reports, which use the Python tools and fonts on Metis;
  - anything interactive or needed soon.

## A permutation job, step by step

1. **Make it work small on Metis first.** Run one chunk of a few permutations.
   - Check that the answer doesn't depend on the number of cores: run the same chunk on 1 core and on 4, and compare.
   - Seeds are fixed, as everywhere in this project.
2. **Split it into chunks.** For example, 10,000 permutations as 20 chunks of 500, with chunk *k* using seed *base* + *k*.
   - Write each chunk to `$SQUIRM_OUT` as soon as it finishes, for example `chunk_07.txt` with one maximum LOD per permutation.
   - Have the script skip any chunk whose file already exists, and end by combining the chunks into the thresholds.
   - If a job is stopped at Squirm's limit (48 hours running, or 7 days in all), its finished chunks still come back. The next job can carry them in its commit, and the script will skip them.
   - A job that Squirm ends to free memory starts over from its commit, so keep each chunk short. A chunk that takes about an hour loses at most an hour.
3. **Put the job's inputs in the commit.** Derived inputs under 100 MB, such as phenotypes and genotypes, can go on the job branch. A new package goes into `installer.R` in the same commit.
4. **Write the job script.** Copy `tools/squirm/job_template.sh` to `squirm_jobs/<name>.sh`, and fill in its header lines: what it computes, Cores, Memory, Expected time and Seeds. Measure the memory on Metis first, from one chunk at the core count you'll ask for.
5. **Commit and push, from Metis:**

   ```
   git switch -c squirm/<name> main
   git add squirm_jobs/<name>.sh <inputs> installer.R
   git commit -m "Squirm job: <name>, <one line on what it computes>"
   git push -u origin squirm/<name>
   ```

   - **The branch's last commit is the job.** Its message must start "Squirm job", and it must add or change exactly one `squirm_jobs/*.sh`. Squirm skips any other commit without a word, so check this if nothing comes back.
   - **To run again,** push a new "Squirm job" commit on top, or use a new branch.

## Results

- **Check:** `git fetch origin squirm/<name>`, then `git log -1 --format=%s FETCH_HEAD`. A finished job's last commit reads "Squirm results: <name> (exit …; … running on … cores; paused … times)".
- **What comes back,** in `output/squirm/<name>/`:
  - the job's own files;
  - `squirm_log.txt`, everything the job printed;
  - `squirm_run.txt`: exit status (and why, if Squirm ended it), cores, the memory stated, time spent running (pauses not counted), start to end, the number of pauses, the machine and the R version.
- **If you pushed to the branch while the job ran,** the results go to `squirm/<name>-results` instead.
- **Bring results to `main`** with a note, labeled planned or exploratory as `CLAUDE.md` asks. Name ATHENA and its R version beside any number from it. If ATHENA's R differs from Metis's, check one chunk on Metis.

## For Rob: setting it up on ATHENA, once

Three steps, then one command. The setup checks each of them, and stops with a plain message at the first that isn't right, before it installs anything.

1. **Make a user for Squirm.** On ATHENA: System Settings, Users & Groups, Add User. Choose **Standard**, account name **squirm**, any password (nobody logs in as it).
2. **Make a token for this repository alone.** On github.com: Settings, Developer settings, Personal access tokens, **Fine-grained tokens**, Generate new token.
   - Repository access: **Only select repositories**, and pick `bxd_mortality_rates_2026`.
   - Permissions: **Contents, Read and write** (Squirm pushes the results). Nothing else.
   - Keep the token to paste in step 4. Squirm stores it for the user `squirm` only.
3. **Make sure R is on ATHENA:** R for Apple silicon from CRAN (cran.r-project.org/bin/macosx), the same version as on Metis. The setup never uses Homebrew.
4. **On ATHENA, in Terminal:**

   ```
   git clone https://github.com/robwwilliams/bxd_mortality_rates_2026.git /tmp/squirm-setup
   sudo bash /tmp/squirm-setup/tools/squirm/setup_athena.sh
   ```

   - It asks for the token; nothing shows as you paste.
   - If it says the user `squirm` can open your home folder, run the `chmod 700` it gives you, and run it again. macOS lets other users look inside home folders unless told not to.

**What it creates:**
- the user `squirm`'s folder `~squirm/squirm`;
- `/Library/Squirm`, holding the runner and its two sandbox profiles, owned by root so a job can't change them;
- `/Users/Shared/squirm`, which is yours for the brake, with a `status` folder that is Squirm's;
- one LaunchDaemon, `com.robwilliams.squirm`, which looks for a job every 5 minutes.

**Day to day:**
- **To see what Squirm is doing:** `cat /Users/Shared/squirm/status/state.txt`. Its history is in `/Users/Shared/squirm/status/squirm.log`.
- **How much memory ATHENA's own work needs:** `/Users/Shared/squirm/status/memory.txt` has a line about every 5 minutes, whether a job is running or not, and also while Squirm is held. Its columns:
  - `free.pct`: macOS's own figure for memory free (from `memory_pressure`), the one Squirm decides by;
  - `used.GB`: memory in use, from that figure;
  - `squirm.GB`: the share of it that is Squirm's job (summed resident memory, which counts shared memory once per process, so it can run high);
  - `athena.GB`: the rest, ATHENA's own work;
  - `squirm`: none, running or paused.
  It records amounts only, never what is running. After a few weeks, for example, the 90th percentile of `athena.GB` is the memory ATHENA's own work stays under 90% of the time. Peaks shorter than 5 minutes can fall between lines.
- **To hold everything:** `touch /Users/Shared/squirm/HOLD`. A running job pauses at the next check, within a minute, and nothing new starts. To release it: `rm /Users/Shared/squirm/HOLD`. Squirm can read the brake but can't remove it.
- **To stop it for good:** `sudo launchctl bootout system/com.robwilliams.squirm`.
- **To update it** after `squirm.sh` changes on `main`: clone again and run the setup again. It refuses while a job is running.
- **A habit for everything else on ATHENA, not only Squirm:** keep work files out of `/private/tmp`. Squirm's sandbox closes that folder to jobs, but the habit keeps the next tool from opening it again.

## How the guest is kept in its place

A job is code from a branch of a public repository, so ATHENA fences it in, rather than trusting it. Four layers do that, each checked by the setup:
1. **A separate user.** Squirm and its jobs run as `squirm`, a Standard user who can't enter Rob's home, where his other projects and his own GitHub login live.
2. **A token for one repository.** `squirm`'s GitHub token reaches this repository alone. The setup stops if it can see any private repository.
3. **macOS's sandbox around every job.**
   - No network, but this machine's own loopback, which R's parallel clusters use.
   - Nothing read under `/Users` or `/Volumes` but Squirm's clone and R library. So a job can't read `squirm`'s token either.
   - The shared temporary folders, `/private/tmp` (where `/tmp` leads) and `/private/var/tmp`, are closed. Any user's processes can leave files there that everyone can read, and pipes that everyone can write. A job gets its own temporary folder, which the runner empties between jobs, and `TMPDIR` points to it.
   - Nothing written but the clone's working tree, and never its `.git`.
   - The setup runs a probe inside the sandbox and stops unless every one of those holds.
4. **A runner that doesn't trust the job's leftovers.** It runs git with no hooks. It returns only what's under `$SQUIRM_OUT`, and drops links a job leaves there. Its own script and profiles belong to root.

## How Squirm decides

- **Busy** means that on average more than 2 programs outside Squirm and its job are running. Squirm counts them 5 times, a second apart, at each check; checks come about every 25 seconds while a job runs.
  - **Two busy checks in a row** pause the job: every process in it receives SIGSTOP. Its memory stays, so nothing is lost.
  - **Three quiet checks in a row** (fewer than 1 running) resume it.
- **A new job starts** only at a quiet moment, with at least 30% of memory free.
- **Memory:** a job that uses more than 1 GB over its stated memory is ended. While a job is paused, if free memory falls under 20%, it's ended and started again later, at most 3 times.
- **Even before a pause, a job yields:** it runs at nice 10, so ATHENA's own work comes first for the cores, and at low disk priority.
- **The tests:** Squirm's runner was tested on Linux, with a stand-in for GitHub and with other programs started and stopped mid-job:
  - pausing and resuming;
  - ending and requeuing on memory;
  - links and planted hooks.
  The setup's stops were tested with stand-ins for macOS's commands, including a sandbox that fences nothing, which the probe caught. The real sandbox can only be checked on ATHENA, and the setup does that before it installs anything. The first job there should be a small one.
