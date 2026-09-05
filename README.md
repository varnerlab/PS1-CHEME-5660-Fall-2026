# PS1: Treasury Valuation, Interest-Rate Risk, and Funding a Future Obligation

Problem Set 1 asks you to value Treasury cash flows and reason about interest-rate risk using the time-value-of-money tools from L1b and the Treasury pricing and yield-curve tools from week 2. This is a finance assignment implemented in a small amount of Julia; it is not a Julia programming assignment.

## Learning objectives

After completing your chosen track, you should be able to:

| Objective | Standard track | Advanced track |
|:--|:--|:--|
| 1. Interpret rate conventions | Convert nominal yields to equivalent continuous rates and value a Treasury bill. | Distinguish a short rate from a price-implied zero yield and investment growth factor. |
| 2. Connect cash flows to risk | Price a coupon note and measure its duration and convexity. | Compare an exact-maturity lock with reinvestment through shorter positions. |
| 3. Evaluate numerical evidence | Compare approximate and exact repricing after a yield shock. | Interpret funding outcomes and recommend a strategy under stated model assumptions. |

## Logistics

- **Release:** Sunday, September 6, 2026.
- **Due:** Sunday, September 20, 2026 at 11:59 PM ET as a ZIP archive uploaded to Canvas.
- **Choose one track:** Complete either Standard or Advanced. Both have a maximum ordinary score of 4; only your selected track is graded.
- **Advanced Magic Point:** An accepted score of 4 on Advanced earns one Magic Point, including a 4 earned through an eligible revision. This bonus is awarded once for PS1.
- **Initial submission:** Submit your current work by the deadline even if it is incomplete or the tests fail. A qualifying submission is a readable ZIP containing the assignment and your attempted work. An empty placeholder or unreadable archive does not qualify. A missing qualifying submission receives a Frozen Zero and is ineligible for revisions or Magic Points.
- **Infinite revisions:** After the initial deadline, eligible students may revise as many times as they like through the end of the semester. Submit each revision using **New Attempt on the same PS1 Canvas assignment**. Canvas may label revisions late; this creates no penalty under the revision policy. Every revision is graded, and the highest score earned is retained.
- **Reference solution:** The reference solution will be released after the initial deadline. Use it to understand mistakes and debug your work, but do not copy it. Your implementation and written explanations must remain your own work. Copying the reference solution results in a score of 0 for the assignment.
- **Group and AI policy:** Submit independent work. You may discuss ideas with classmates, but may not directly share code or solutions. You may use Julia documentation, AI tools, and internet resources; you remain responsible for understanding and explaining everything you submit.

## This is not a Julia programming assignment

The supplied code reads the data, constructs the note's cash-flow schedule, organizes the CIR scenarios, and runs the tests. You complete only short expressions that translate displayed financial equations into Julia.

You do **not** need to:

- define a custom type;
- parse a CSV file;
- construct a coupon schedule;
- write a scenario loop;
- implement or calibrate CIR; or
- create a notebook.

Set your selection in `TRACK.txt`, then edit the source and finance-response files for your chosen track:

- Standard: `src/Standard.jl` and `responses/Standard.md`
- Advanced: `src/Advanced.jl` and `responses/Advanced.md`

Keep any additional solution helpers inside `src`. Do not edit `src/Support.jl`, the data, public tests, reports, or checkers to make an incomplete solution appear to pass. Replace each placeholder error with your expression and remove or update its completed `TODO` comment; keep the function docstrings.

## Getting started

This assignment is supported with **Julia 1.12.7** and uses only Julia standard libraries.

1. Open the [PS1 Releases page](https://github.com/varnerlab/PS1-CHEME-5660-Fall-2026/releases) and select the tagged PS1 release announced on Canvas.
2. Under **Assets**, download **Source code (zip)**. Extract the archive completely, then open the extracted folder in VS Code. This is the folder containing `README.md`, `Project.toml`, and `check_submission.jl`.
3. Open a terminal in that folder and prepare the supplied environment:

   ```text
   julia --project=. -e 'using Pkg; Pkg.instantiate()'
   ```

4. Put exactly `standard` or `advanced` in `TRACK.txt` and complete the selected source and response files.
5. Check your progress:

   ```text
   julia --project=. --startup-file=no check_submission.jl
   ```

The starter code intentionally contains `TODO` comments and placeholder errors. **The public tests are expected to fail before you begin.** A failure message identifies work still to do; a setup or syntax error is reported separately.

You can also run the selected test suite directly:

```text
julia --project=. --startup-file=no testme_standard.jl
julia --project=. --startup-file=no testme_advanced.jl
```

Run only the line for your chosen track. Individual formula checks use supplied inputs so unfinished upstream calculations do not erase credit for other formulas. Each track also includes a check of the complete calculation. See [RUBRIC.md](RUBRIC.md) for the exact scoring procedure.

## Displaying your results

Run this command to display the numerical results needed for your three written responses:

```text
julia --project=. --startup-file=no report_results.jl
```

It reads `TRACK.txt`, calls your functions, and prints labeled values with units. For partial solutions, available results are displayed and calculations that cannot run are labeled `UNAVAILABLE`. The report shows your calculations; use the public tests to check their correctness. You do not need to write a separate driver or extract values from the test files.

In the selected response file, replace each placeholder with two to four sentences. Keep the `<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers around each answer. The checker uses these markers to detect empty or missing answers; the teaching team reviews their substance. Report prices in USD and rates as percentages. Keep at least four decimal places when comparing the small Standard repricing error.

## The setting

Treasury cash flows support two related investigations. Standard prices a six-month bill and a seven-year coupon note, then measures the note's sensitivity to a yield change. Advanced considers a firm that owes a fixed payment in seven years and compares locking in that payment with rolling shorter investments.

## Standard track: price and measure interest-rate exposure

The Standard track follows the lecture sequence directly:

1. Convert a nominal yield to its equivalent continuously compounded growth rate.
2. Price a zero-coupon Treasury bill and recover its price-implied growth rate.
3. Discount the promised cash flows of a seven-year coupon note.
4. Compute the note's Macaulay duration, modified duration, and convexity.
5. Estimate the price effect of a 50-basis-point yield increase and compare the approximation with exact repricing.

The supplied `standard-terms.csv` file contains the classroom security terms. The support code constructs the note schedule, leaving only the financial formulas as TODOs in `src/Standard.jl`. Complete the three short interpretations in `responses/Standard.md` after the calculations work.

## Advanced track: lock versus roll under uncertain future rates

The firm owes

$$
L=\$100{,}000
$$

at the end of period 7. Each period is one classroom year. Compare two strategies that use the same initial capital. Assume timely promised payments, divisible positions, and no taxes or transaction costs.

### Lock strategy

Buy an exact-maturity principal STRIP. If $P(0,7)$ is its price per dollar of maturity value, the amount invested today is

$$
W_0=L\,P(0,7).
$$

Holding the STRIP to maturity funds the liability exactly under the model assumptions.

### Roll strategy

Invest the same $W_0$ in a sequence of seven one-period zero-coupon Treasury positions. In scenario $s$,

$$
W_7^{(s)}
=
W_0\prod_{k=1}^{7}G_k^{(s)},
\qquad
G_k^{(s)}=\frac{1}{P_k^{(s)}}.
$$

For every scenario, measure the funding ratio and shortfall:

$$
\text{funding ratio}^{(s)}=\frac{W_7^{(s)}}{L},
$$

$$
\text{shortfall}^{(s)}=\max\left(L-W_7^{(s)},0\right).
$$

Then summarize the fraction of the 40 equally weighted scenarios that fully fund the liability, mean terminal value, mean shortfall across all scenarios, and maximum observed shortfall. Here, “funding probability” means this scenario fraction. It is not a real-world forecast; the maximum observed shortfall is not a bound on every possible loss.

After the calculations work, complete the three short interpretations and recommendation in `responses/Advanced.md`.

### Where the rates came from

L1b defined the discount factor associated with a possibly time-varying continuously compounded growth rate $g(u)$:

$$
\mathcal D_{T,t}^{-1}(g)
=
\exp\left(-\int_t^T g(u)\,du\right).
$$

The CIR model makes that rate stochastic and mean reverting:

$$
dr_t=\kappa(\theta-r_t)\,dt+\sigma\sqrt{r_t}\,dW_t.
$$

The teaching team used CIR to generate frozen short-rate paths and model-implied one-period zero-coupon prices. You use the supplied data; you do not run the model.

The CIR short rate and the one-period zero yield are different quantities. Use the supplied zero-coupon price or its growth factor to roll the portfolio. Do not substitute the short rate directly into an accumulation formula.

These are synthetic model-implied Treasury rates, not predictions of future auction results. For this assignment, the same CIR parameters are used for scenario generation and pricing, suppressing the physical-versus-risk-neutral distinction.

## Scoring

The grading rubric matches the course's 0-to-4 policy. Standard has **13 public checks** and Advanced has **16**. Passing strictly more than half earns a 2 when some checks still fail. All checks must pass for a 3 or 4; a 4 additionally requires accepted documentation, implementation, and all three finance responses. Only the selected track's work is subject to completion review.

The local checker reports feedback, not an official grade. When all numerical checks pass, the result is **pending completion review**. A final 3 means an applicable requirement was actually found incomplete or unacceptable; it is not the default while grading is pending. See [RUBRIC.md](RUBRIC.md) for the full score table and official grading procedure.

## Checking and submitting your work

Run:

```text
julia --project=. --startup-file=no check_submission.jl
```

The checker runs the selected public tests, checks for docstrings and text in all three answer blocks, and creates `MANIFEST.txt` with source and response fingerprints.

**This script does not connect to Canvas or upload your work.** If checks need attention, fix as much as you can and rerun it. Submit your current readable work before the deadline even if some tests fail or cannot run, so you preserve eligibility for revisions.

1. Zip the entire extracted problem-set folder, including `TRACK.txt`, `src`, `responses`, `data`, and the generated `MANIFEST.txt`.
   - macOS: right-click the folder in Finder and choose **Compress**.
   - Windows: right-click the folder and choose **Send to → Compressed (zipped) folder**.
2. Rename the ZIP to `CHEME-5660-PS1-<your netid>.zip`. Replace the entire `<your netid>` placeholder, including angle brackets, with your actual NetID. For example: `CHEME-5660-PS1-abc123.zip`.
3. Upload the ZIP to the PS1 assignment on Canvas by the initial deadline.
4. For an eligible revision, rerun the checker, create an updated ZIP, and use **New Attempt** on that same Canvas assignment. Revisions remain available through the end of the semester; the highest score is retained.
