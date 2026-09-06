# PS1: Treasury Valuation, Interest-Rate Risk, and Funding a Future Obligation

In Problem Set 1 (PS1), you will value Treasury cash flows and analyze interest-rate risk using the time-value-of-money tools from L1b and the Treasury pricing and yield-curve tools from L2a and L2b.

## Learning objectives

After completing your chosen track, you should be able to:

| Objective | Standard track | Advanced track |
|:--|:--|:--|
| 1. Interpret rate conventions | Convert nominal yields to equivalent continuous rates and value a Treasury bill. | Distinguish a short rate from the price-implied growth rate $g_B$ and investment growth factor. |
| 2. Connect cash flows to risk | Price a coupon note and measure its duration and convexity. | Track principal, coupons, whole-lot reinvestment, and residual cash across investment sequences. |
| 3. Evaluate numerical evidence | Compare approximate and exact repricing after a yield shock. | Compare funding reliability and shortfalls across the same simulated futures. |

## Logistics

- **Dates:** PS1 is released on September 6, 2026. Upload your ZIP to Canvas by **September 20, 2026 at 11:59 PM ET**.
- **Track and score:** Choose Standard or Advanced. Your selected track is graded out of 4 points. Earning an accepted 4 on Advanced also earns one Magic Point. You can earn this bonus through an eligible revision, but only once for PS1.
- **Initial submission:** Submit a readable ZIP containing the assignment and your attempted work by the deadline, even if incomplete or tests fail. Missing, empty, or unreadable submissions receive a Frozen Zero with no revisions or Magic Points.
- **Infinite revisions:** Eligible students may revise through semester's end using **New Attempt on the same PS1 Canvas assignment**. We grade every revision and keep your highest score. Canvas late labels carry no penalty.
- **Independent work:** You may discuss ideas and use documentation, AI tools, and internet resources. Submit your own work and be able to explain it. Do not share code or solutions. Use the reference solution released after the deadline to understand mistakes and debug your work. Copying it earns a 0. See [RUBRIC.md](RUBRIC.md) for details.

## Complete your work

Set your selection in `TRACK.txt`, then edit the source and discussion-question files for your chosen track:

- Standard: `src/Standard.jl` and `responses/Standard.md`
- Advanced: `src/Advanced.jl` and `responses/Advanced.md`

Keep any additional solution helpers inside `src`. Leave the supplied `src/Support.jl`, `src/Sequences.jl`, data, public tests, reports, and checkers unchanged. Replace each placeholder error with your expression and remove or update its completed `TODO` comment. Keep the function docstrings.

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

The starter code intentionally contains `TODO` comments and placeholder errors. **The public tests are expected to fail before you begin.** Failure messages identify work still to do. The checker reports setup and syntax errors separately.

You can also run the selected test suite directly:

```text
julia --project=. --startup-file=no testme_standard.jl
julia --project=. --startup-file=no testme_advanced.jl
```

Run only the line for your chosen track. Individual formula checks use supplied inputs so unfinished upstream calculations do not erase credit for other formulas. Each track also includes checks of the complete calculation. See [RUBRIC.md](RUBRIC.md) for the exact scoring procedure.

## Displaying your results

`check_submission.jl` automatically displays the numerical results needed for your answers to the three discussion questions after running the public tests. It reads `TRACK.txt`, calls your functions, and prints labeled values with units. For partial solutions, available results are displayed and calculations that cannot run are labeled `UNAVAILABLE`. Use the test results to check the correctness of these values.

In the selected response file, replace each placeholder with two to four sentences. Keep the `<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers around each answer. The checker uses these markers to detect empty or missing answers. The teaching team reviews the answers. Report prices in USD and rates as percentages. Keep at least four decimal places when comparing the small Standard repricing error.

## The setting

Treasury cash flows support two related investigations. Standard prices a six-month bill and a seven-year coupon note, then measures the note's sensitivity to a yield change. Advanced considers a firm that owes a fixed payment in seven years and compares every permitted sequence of Treasury investments with a maturity-matched STRIP benchmark.

## Standard track: price and measure interest-rate exposure

The Standard track follows the lecture sequence directly:

1. Convert a nominal yield to its equivalent continuously compounded growth rate.
2. Price a zero-coupon Treasury bill and recover its price-implied growth rate.
3. Discount the promised cash flows of a seven-year coupon note.
4. Compute the note's Macaulay duration, modified duration, and convexity.
5. Estimate the price effect of a 50-basis-point yield increase and compare the approximation with exact repricing.

The supplied `standard-terms.csv` file contains the security terms. Complete the financial formulas marked `TODO` in `src/Standard.jl`, then answer the three discussion questions in `responses/Standard.md`.

## Advanced track: which investment sequences fund the obligation?

A firm owes **$100,000 at the end of year 7**. It has the amount needed today to purchase a seven-year principal STRIP with $100,000 par: approximately **$74,967.84**. Compare that benchmark with every permitted sequence of investments using exactly the same starting budget. The task is to evaluate how cash-flow timing and future reinvestment prices affect funding reliability.

Assume all securities make their promised payments. There is no borrowing, no early sale, no additional contribution, and no tax or transaction cost. These are synthetic securities with the supplied prices and terms.

### Available securities and permitted sequences

| Label | Security | Holding time | Payments per $10,000 par |
|:--|:--|:--|:--|
| `B1` | One-year zero-coupon bill | 1 year | $10,000 at maturity |
| `N2` | Two-year coupon note | 2 years | $212.50 every six months, plus $10,000 principal at maturity |
| `N3` | Three-year coupon note | 3 years | Same coupon rule |
| `N5` | Five-year coupon note | 5 years | Same coupon rule |
| `N7` | Seven-year coupon note | 7 years | Same coupon rule |
| `STRIP7` | Benchmark principal STRIP | 7 years | $10,000 at maturity, with no coupons |

All notes have a fixed annual coupon rate of **4.25%**, paid semiannually ($n=2$). Their prices vary with the market scenarios.

A main investment sequence is an **ordered list of holding times drawn from 1, 2, 3, 5, and 7 years that totals exactly seven years**. The supplied code enumerates all **50** such sequences. For example:

- `N7`: hold a seven-year note.
- `N5-B1-B1`: hold a five-year note, then two successive one-year bills.
- `N2-B1-B1-B1-B1-B1`: hold a two-year note, then five successive one-year bills.
- `N2-N5`: hold a two-year note, then a five-year note.
- `B1-N5-B1`: hold a bill, then a five-year note, then a bill.

Sequence order matters: `N2-N5` and `N5-N2` make their later purchases at different dates and deliver coupons on different schedules. Every main security is held to maturity before the next main purchase. The STRIP is evaluated separately as the 51st strategy.

**Choose a sequence before observing the future.** Its later purchases can use prices available on their purchase dates, but cannot use later scenario values. We evaluate each fixed sequence across all 40 futures. Selecting the winning sequence separately after seeing each completed future would give the investor foresight.

Each sequence holds one main security at a time. Six-month bills handle coupons and residual cash under the common rule below.

### Whole lots, coupons, and residual cash

For this assignment, purchases must be in **whole lots of $10,000 par**. Market-table prices are in USD per $100 par, so the supplied code multiplies each quote by 100 to obtain the purchase price of a $10,000-par lot. Par value and purchase cost are different quantities.

At time 0 and every six months thereafter, use this same rule for every sequence:

1. Combine carried cash, coupons received, and any maturing principal, including the six-month bills bought on the preceding date.
2. If a main investment is due, buy as many whole lots of that security as the available cash permits. At time 0, buy the first main security. At its maturity, buy the next one in the predeclared sequence.
3. Use the remaining cash to buy as many whole **six-month zero-coupon bill lots** as possible. These bills mature at the next accounting date. This reinvests coupons and other available cash through one common rule.
4. Carry any remainder as **cash earning zero interest**. If no lot is affordable, buy zero lots. The predeclared main purchase dates still apply.
5. At year 7, collect the final coupons and all maturing principal. Make no further purchases. Total cash at this date is the strategy's terminal wealth.

For example, $25,000 cash and a bill price of $9,800 per $10,000-par lot allow two lots, leaving $5,400 cash. At maturity, those lots pay $20,000. Adding the carried cash gives you $25,400 for the next purchase. Fractional lots and borrowing are not allowed.

The STRIP benchmark buys ten $10,000-par lots at time 0 and receives $100,000 at year 7. Buying an `N7` position with the same budget may purchase less than $100,000 par. Its coupons and residual cash must therefore be tracked even though its final maturity matches the obligation.

### What you implement

Complete nine financial expressions in `src/Advanced.jl`:

1. Price-implied growth rate $g_B$ from L2a.
2. Affordable whole-lot count: $q=\lfloor B/V_{\mathrm{lot}}\rfloor$.
3. Residual cash: $B-qV_{\mathrm{lot}}$.
4. Coupon payment on held par: $C=V_Pc/n$.
5. Funding ratio: $W_7/L$.
6. Shortfall: $\max(L-W_7,0)$.
7. Fraction of scenarios that fund the liability.
8. Mean shortfall across all scenarios, including zero in funded scenarios.
9. Maximum observed shortfall.

Here $B$ is available cash, $V_{\mathrm{lot}}$ is one lot's purchase price, $V_P$ is the held par amount, $c$ is the annual coupon rate, and $L=100{,}000$ USD. The supplied code handles sequence enumeration, purchase dates, coupon schedules, and scenario iteration. Unlike a fractional-investment calculation, multiplying the entire budget by a growth factor would incorrectly give investment returns to cash that could not buy a whole lot.

### Where the multiple futures come from

Each scenario is one possible seven-year market path, observed every six months. All scenarios start from the same market conditions. The same scenario is used for every strategy, so comparisons reflect the investment rules rather than different random futures.

The teaching team uses **CIR** to simulate the instantaneous short rate $r_t$: a stochastic version of the time-varying growth rate $g(t)$ inside L1b's discounting integral. CIR does **not** directly simulate the quoted nominal yield $y$. Its pricing formula converts the current rate state into prices of future payments. A note's price is then the sum of its discounted coupons and principal, following the cash-flow valuation in L2a and the maturity-specific discount factors in L2b. Prices on a purchase date use the rate state on that date, never the later realized path.

Use the supplied security-price table for all calculations. The same CIR parameters generate the scenarios and prices. The funded fraction measures success across these 40 synthetic paths. Its interpretation depends on the model assumptions and sampled paths. Severe stress cases may fall outside this sample.

For a zero-coupon price $P$ per dollar of maturity value and remaining holding time $T$ years, retain L2a's notation:

$$
g_B=\frac{1}{T}\log\left(\frac{1}{P}\right).
$$

L1b's benchmark is $g_y=2\log(1+y/2)$ under the nominal-yield convention $n=2$. Equality $g_B=g_y$ requires that $P$ equal the zero-NPV price at that chosen $y$. Advanced infers $g_B$ from the supplied price and does not assume equality with an independently chosen benchmark. A one-year holding time spans two semiannual compounding intervals, so $n=2$. The model's instantaneous $r_t$ is also distinct from this finite-horizon $g_B$.

### Read and interpret the results

The single `check_submission.jl` command prints the initial budget, initial `N7` holdings, and the complete strategy comparison. It also writes:

- `results/advanced-strategies.csv`: the funded scenario count and fraction, mean terminal wealth, mean shortfall, and maximum observed shortfall for all 50 sequences and the STRIP.
- `results/advanced-scenario-outcomes.csv`: terminal wealth, funding ratio, and shortfall for each strategy in each scenario. Matching `scenario_id` values refer to the same future.

Use these results to complete the three discussion questions in `responses/Advanced.md`. Compare both reliability and the size of deficits: the strategy with the largest funded fraction need not have the smallest average or maximum shortfall. The comparison covers the permitted strategies and supplied scenarios. Larger shortfalls may occur under other market paths.

## Scoring

The grading rubric matches the course's 0-to-4 policy. Standard has **13 public checks** and Advanced has **16**. Passing strictly more than half earns a 2 when some checks still fail. All checks must pass for a 3 or 4. A 4 also requires accepted documentation, implementation, and answers to all three discussion questions. Only the selected track's work is subject to completion review.

The local checker reports feedback, not an official grade. When all numerical checks pass, the result is **pending completion review**. A final 3 means the teaching team found an applicable requirement incomplete or unacceptable. Work awaiting review remains pending. See [RUBRIC.md](RUBRIC.md) for the full score table and official grading procedure.

## Checking and submitting your work

Run:

```text
julia --project=. --startup-file=no check_submission.jl
```

The checker runs the selected public tests, displays your financial results, checks for docstrings and text in all three answer blocks, and creates `MANIFEST.txt` with source and response fingerprints.

**This script does not connect to Canvas or upload your work.** If checks need attention, fix as much as you can and rerun it. Submit your current readable work before the deadline even if some tests fail or cannot run, so you preserve eligibility for revisions.

1. Zip the entire extracted problem-set folder, including `TRACK.txt`, `src`, `responses`, `data`, and the generated `MANIFEST.txt`.
   - macOS: right-click the folder in Finder and choose **Compress**.
   - Windows: right-click the folder and choose **Send to → Compressed (zipped) folder**.
2. Rename the ZIP to `CHEME-5660-PS1-<your netid>.zip`. Replace the entire `<your netid>` placeholder, including angle brackets, with your actual NetID. For example: `CHEME-5660-PS1-abc123.zip`.
3. Upload the ZIP to the PS1 assignment on Canvas by the initial deadline.
4. For an eligible revision, rerun the checker, create an updated ZIP, and use **New Attempt** on that same Canvas assignment. You may revise through the end of the semester. We keep your highest score.
