# CTL scan, copied here for ATHENA

These files are copies, made on 26 November 2026, for the Squirm job `squirm/bxd_ctl_scan`. A Squirm job can read only this repository.
- **The code** is from [robwwilliams/BxDLifeSpan](https://github.com/robwwilliams/BxDLifeSpan) at commit 21e73f8:
  - `ctl_functions.R` and `ctl_scan.R`: the scan (unchanged since 0132d5f);
  - `ctl_strain_subsets.R`: whether each test's P values are right, measured on random splits of the strains;
  - `effective_Tages.R`: how many independent tests the 25 T-ages add.
- **The inputs** in `inputs/` (`mice.txt`, `genotypes.txt`) were made there by `ctl_inputs.R` from the fork's data, using Danny Arends's `shared.R` and `adjust.R`.

**Don't edit these copies.** Change the code in the fork, test it there (`ctl_tests.R`), and copy it again.

What the scan does, the checks and the results so far: the fork's [`MODELS_for_Danny.md`](https://github.com/robwwilliams/BxDLifeSpan/blob/master/MODELS_for_Danny.md), section 4.
