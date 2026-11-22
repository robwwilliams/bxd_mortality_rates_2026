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
   - at most 16 GB of memory;
   - no output file over 100 MB. GitHub refuses larger files, so Squirm keeps them on ATHENA and lists them in `squirm_run.txt`.
5. **A job stays inside its own space.**
   - It runs in Squirm's own clone of this repository, at the commit that added it.
   - It reads only what that commit holds. `data/local/` isn't on ATHENA.
   - It writes only under `$SQUIRM_OUT`.
   - No network and no installs. The R packages come from `installer.R`, which Squirm installs into its own library before the job starts.
6. **Leave the rest of ATHENA alone.**
   - Other folders on ATHENA belong to Rob's other projects, some of them private. Never list, read or copy them, and never name or describe anything about them here. This repository is public.
   - Never change Homebrew, system settings or launchd agents on ATHENA.
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
3. **Put the job's inputs in the commit.** Derived inputs under 100 MB, such as phenotypes and genotypes, can go on the job branch. A new package goes into `installer.R` in the same commit.
4. **Write the job script.** Copy `tools/squirm/job_template.sh` to `squirm_jobs/<name>.sh`, and fill in its header lines: what it computes, Cores, Memory, Expected time and Seeds.
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
  - `squirm_run.txt`: exit status, cores, time spent running (pauses not counted), start to end, the number of pauses, the machine and the R version.
- **If you pushed to the branch while the job ran,** the results go to `squirm/<name>-results` instead.
- **Bring results to `main`** with a note, labeled planned or exploratory as `CLAUDE.md` asks. Name ATHENA and its R version beside any number from it. If ATHENA's R differs from Metis's, check one chunk on Metis.

## For Rob: setting it up on ATHENA, once

On ATHENA, in Terminal:

```
git clone https://github.com/robwwilliams/bxd_mortality_rates_2026.git ~/Code/squirm/bxd
bash ~/Code/squirm/bxd/tools/squirm/setup_athena.sh
```

- **R:** the setup needs R on ATHENA. If R is missing, it stops and says so. Install R for Apple silicon from CRAN, the same version as on Metis, and run the setup again. The setup never uses Homebrew.
- **What it creates:** `~/Code/squirm` and one launchd agent, `com.robwilliams.squirm`, which looks for a job every 5 minutes.
- **To see what Squirm is doing:** `cat ~/Code/squirm/state.txt`. Its history is in `~/Code/squirm/squirm.log`.
- **To hold everything:** `touch ~/Code/squirm/HOLD`. A running job pauses at the next check, within a minute, and nothing new starts. To release it: `rm ~/Code/squirm/HOLD`.
- **To stop it for good:** `launchctl bootout gui/$(id -u)/com.robwilliams.squirm`.
- **To update it** after `squirm.sh` changes on `main`, run the setup again. It refuses while a job is running.

## How Squirm decides

- **Busy** means that on average more than 2 programs outside Squirm and its job are running. Squirm counts them 5 times, a second apart, at each check; checks come about every 25 seconds while a job runs.
  - **Two busy checks in a row** pause the job: every process in it receives SIGSTOP. Its memory stays, so nothing is lost.
  - **Three quiet checks in a row** (fewer than 1 running) resume it.
- **A new job starts** only at a quiet moment, with at least 30% of memory free.
- **Even before a pause, a job yields:** it runs at nice 10, so ATHENA's own work comes first for the cores, and at low disk priority.
- **The tests:** Squirm's tests were run on Linux, with a stand-in for GitHub and with other programs started and stopped mid-job. The first run on ATHENA should be a small job.
