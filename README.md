# PS1: Treasury Valuation, Interest-Rate Risk, and Funding a Future Obligation

In Problem Set 1 (PS1), you will value Treasury cash flows and analyze interest-rate risk using the time-value-of-money, Treasury pricing, and sensitivity tools from lecture.

Choose one track. **Standard** examines how Treasury prices respond to a change in yield. **Advanced** includes those valuation tasks and adds a decision about funding a payment due in seven years.

After completing your chosen track, you should be able to interpret interest rates, connect Treasury cash flows to risk, and use your results to reason about funding and interest-rate risk.

__Logistics__:

* __Dates:__ PS1 is released on Sunday, September 6, 2026 and is due as a ZIP archive uploaded to Canvas by **11:59 PM ET on Sunday, September 20, 2026**. You must submit __something__ by the deadline to be eligible for the infinite-revision policy. Submit a readable ZIP containing your attempted work, even if incomplete or tests fail. A missing, empty, or unreadable submission receives a score of `0` and locks you out of the infinite-revision policy and Magic Points for this assignment.
* __Infinite-revision policy:__ After the due date, you may revise and resubmit your work as many times as you like until **December 19, 2026 at 11:59 PM ET**, the last day of academic activity. Each resubmission will be graded, and the highest score will be recorded. Use **New Attempt** on the same Canvas assignment. Canvas late labels carry no penalty for eligible revisions. The reference solution will be published in this repository after the due date. Use it to check your work, understand mistakes, and debug your code, __but you may not copy it__. We check for plagiarism, and copying the reference solution will result in a locked score of `0` for this assignment.
* __Group and AI Policy:__ Students are expected to submit independent work on this assignment. You may discuss the problem set with classmates, but you may not directly share code or solutions. You are allowed to use any resources you like, including the Julia documentation, AI tools, and the internet.

Your selected track is graded out of **4 points**. A score of `4` on the Advanced track also earns **one Magic Point**, including through an eligible revision. The bonus is awarded once for PS1. See [RUBRIC.md](RUBRIC.md) for the grading rules and completion review.

## Getting started

This assignment was built and tested with **Julia 1.12.7** and uses `VLQuantitativeFinancePackage`, the same package used in the lecture examples.

1. Open the [PS1 Releases page](https://github.com/varnerlab/PS1-CHEME-5660-Fall-2026/releases) and select the release announced on Canvas.
2. Under **Assets**, download **Source code (zip)** and extract the archive. In VS Code, choose **File → Open Folder** and select the extracted PS1 folder containing `README.md`, `Project.toml`, and `check_submission.jl`. Or open VS Code from the command line with `code <path-to-extracted-folder>`.
3. In VS Code, choose **Terminal → New Terminal**. From the extracted PS1 folder containing `Project.toml`, run this setup command once to install the recorded package versions:

   ```text
   julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
   ```

   The first setup needs an internet connection and may take several minutes.
4. Open `TRACK.txt` in the extracted PS1 folder, replace its contents with exactly `standard` or `advanced`, and save the file. The starter file already contains `standard`.

## Complete your work

Edit the two files for your chosen track:

| Track | Code | Discussion questions |
|:--|:--|:--|
| Standard | [src/Standard.jl](src/Standard.jl) | [responses/Standard.md](responses/Standard.md) |
| Advanced | [src/Advanced.jl](src/Advanced.jl) | [responses/Advanced.md](responses/Advanced.md) |

**Changing tracks:** You may switch between Standard and Advanced before submitting or on an eligible revision. Each submission is graded only on the track selected in `TRACK.txt`. If you change tracks, update `TRACK.txt`, complete that track's code and response files, and rerun the checker. You may reuse your own valuation code, but the discussion questions differ between tracks. We keep your highest score across all submissions, even if you change tracks. An unfinished Advanced submission is graded under the Advanced rubric; it does not automatically receive a Standard grade.

Complete the `TODO` items in your source file using the instructions above each function. Replace the starter error statements with your code, remove completed `TODO` comments, and keep the function docstrings. Put any helper functions in your track file. If you prefer a separate file under `src`, load it from your track file with `include(joinpath(@__DIR__, "MyHelpers.jl"))`, replacing `MyHelpers.jl` with its filename. Leave the supplied support code, data, tests, reports, and checker unchanged.

Save your code and run the [submission checker](#checking-and-submitting-your-work) to generate your results. The financial results appear in the terminal after the test report. The checker loads the supplied data and calls your functions.

__Use your results to answer the three discussion questions in your track's response file__. Open the `responses` directory and edit [responses/Standard.md](responses/Standard.md) for Standard or [responses/Advanced.md](responses/Advanced.md) for Advanced. Edit the Markdown source in VS Code and replace each `TODO: Write your response here.` line with your answer. Explain your reasoning and include the requested values, using tables where useful. Keep the `<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers around each answer. Report monetary values in USD and rates as percentages. Save your response file and rerun the checker before creating your ZIP.

### Standard track

An investor is comparing a Treasury bill and a coupon note. Your job is to price both investments and assess how a rise in interest rates would affect the note's value.

Use the package calls from the lecture examples to price a six-month Treasury bill and a seven-year coupon note. Then reprice a copy of the note after its yield rises by **50 basis points**.

* __Note__: One basis point is 0.01 percentage points, so 50 basis points is 0.50 percentage points. In this assignment, the note's yield increases from **4.60% to 5.10%**. The note's coupon rate stays at 4.25%.

Complete three tasks in `src/Standard.jl`: build and price the bill, build and price the note, and reprice the note at the higher yield. Use `build(...)`, `DiscreteCompoundingModel()`, and `deepcopy(...)` as demonstrated in L2a and L2b. The docstrings list the model fields and supplied inputs. Follow the [bill pricing](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187/lectures/week-2/L2a/CHEME-5660-L2a-TBills-Pricing-Fall-2026-WorkedExample.ipynb), [note pricing](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187/lectures/week-2/L2a/CHEME-5660-L2a-NotesBonds-Pricing-Fall-2026-WorkedExample.ipynb), and [repricing](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187/lectures/week-2/L2b/CHEME-5660-L2b-Example-Treasury-Duration-Convexity-Fall-2026.ipynb) examples.

The checker also calculates an **estimated new note price using duration and convexity**. This is the second-order Taylor approximation from L2b:

$$
V_{\mathrm{est}} = V_B(y)\left[1-D_{\mathrm{mod}}\Delta y+\frac{1}{2}K(\Delta y)^2\right].
$$

Here, $V_B(y)$ is the original note price, $D_{\mathrm{mod}}$ is its modified duration, $K$ is its convexity, and $\Delta y=0.005$ is the yield increase. Duration describes the price's sensitivity to yield. Convexity adjusts the estimate for curvature in the price-yield relationship. The checker supplies both measures and the estimated new price.

Compare this estimated price with the note price recalculated by the package at the higher yield. Report the package price minus the estimated price in USD per USD 100 par. Use the checker's **Package price minus estimated note price** result, which is calculated before rounding. You may round reported values to four decimal places.

The security terms are in [data/standard-terms.csv](data/standard-terms.csv).

### Advanced track

A firm has **USD 74,000 today** and must pay **USD 100,000 at the end of year 7**, but it cannot borrow or add more money. Your job is to choose among four Treasury investment strategies and explain the risk of missing that payment.

**Advanced includes the Standard valuation and repricing tasks, then adds a funding comparison.** Complete both parts using [src/Advanced.jl](src/Advanced.jl) and [responses/Advanced.md](responses/Advanced.md):

1. **Complete the Standard valuation work.** Implement `build_bill`, `build_note`, and `reprice_note` in `src/Advanced.jl`, following the Standard-track instructions. Answer Question 1 in `responses/Advanced.md` about these results.
2. **Complete the funding comparison.** Implement `compare_strategies` by passing the four bill-and-note sequences below to the supplied `evaluate_sequences` function. Answer Questions 2 and 3 in `responses/Advanced.md`.

All four functions are already included in the Advanced starter file. You only need to edit the Advanced files.

The funding comparison uses separate simulated market prices. The purchase price of its seven-year note (`N7`) need not equal the note price from the valuation exercise.

All four strategies start with the same **USD 74,000**. Later purchases use only cash from the investments and any cash held over.

| Strategy | What the firm buys |
|:--|:--|
| `N7` | A seven-year note held to maturity |
| `N2-N5` | A two-year note, then a five-year note |
| `N5-N2` | A five-year note, then a two-year note |
| `B1-B1-B1-B1-B1-B1-B1` | A one-year bill, replaced at maturity each year for seven years |

Each sequence is chosen before the future is known. The firm holds each main security (the note or bill named in the sequence) to maturity, then uses the available cash to buy the next security. Order matters because purchases and coupon payments occur at different times.

All purchases use whole lots of **USD 10,000 par**. Notes have a fixed **4.25% annual coupon**, paying **USD 212.50 per lot every six months**. The coupon stays fixed while market prices change. Coupons and leftover cash are invested in whole lots of six-month bills, with any remaining cash held at zero interest. The supplied code handles these purchases, payments, and reinvestments.

#### Compare the results and recommend a funding plan

Run `check_submission.jl` after completing `src/Advanced.jl`. Open `results/advanced-strategies.csv`, which reports all four strategies across the same **40 simulated futures**, and answer Questions 2 and 3 in [responses/Advanced.md](responses/Advanced.md):

1. **Compare the four strategies.** Report how many futures meet the payment, the mean cash available at year 7, the mean shortfall, and the largest shortfall. Explain why `N2-N5` and `N5-N2` give different results.
2. **Recommend a strategy.** Choose one of the four strategies for the fixed **USD 74,000** budget. Use the funding counts and shortfall amounts to justify your choice. Explain the risk of missing the required payment and one limitation of using the 40 simulated futures to judge funding reliability.

**Shortfall** is the amount still needed to make the payment: USD 95,000 available means a USD 5,000 shortfall. USD 100,000 or more means zero shortfall. Mean shortfall includes those zeros.

#### Reference: how cash is reinvested

At time 0 and every six months through year 6.5, the supplied code:

1. Collects coupons, maturing principal, and cash carried forward.
2. Buys as many whole lots of the scheduled main security as the available cash allows, at time 0 or when the previous main security matures.
3. Invests the remaining cash in as many whole six-month bill lots as it can afford, carrying any leftover cash at zero interest.

If no lot is affordable, the code buys zero lots and keeps the scheduled purchase dates. At year 7, it collects all final payments and stops investing. All securities make their promised payments. There is no borrowing, early sale, tax, transaction cost, or additional contribution. Coupons are part of the investment cash flows, not new money from the firm.

## Checking and submitting your work

Save your edited files. When you are done, or when you have gone as far as you can, run `check_submission.jl`. Partial solutions earn partial credit. In VS Code, choose **Terminal → New Terminal** and run this command from the extracted PS1 folder containing `Project.toml` and `check_submission.jl`:

```text
julia --project=. --startup-file=no check_submission.jl
```

**This script does not connect to Canvas or upload your work.** It runs your selected track's tests, displays your financial results, and writes `MANIFEST.txt` to record your submission. If a test fails, review the failure, fix as much as you can, and run the script again. If the deadline is imminent, submit your current work even if tests fail or cannot run. A readable submission containing attempted work keeps you eligible for partial credit and the infinite-revision policy.

Tests are expected to fail until you complete the starter code. Calculations that cannot yet run appear as `UNAVAILABLE`.

For Advanced, the checker also saves `results/advanced-strategies.csv` with the strategy comparison and `results/advanced-scenario-outcomes.csv` with results for each future. Matching `scenario_id` values identify the same future across strategies.

To earn a 4, all tests must pass and the teaching team must accept your code, documentation, and discussion answers. The checker flags missing docstrings and unfinished answers, but the teaching team reviews their substance. Passing all tests shows the status **pending completion review** until that review is finished. The score table is in [RUBRIC.md](RUBRIC.md).

When your work is ready, or before the deadline if you cannot resolve every failure, ZIP the entire extracted PS1 folder and upload it manually to the PS1 assignment on Canvas. Include everything: your `src` and `responses` files, the `data` folder, `Project.toml`, `Manifest.toml`, `TRACK.txt`, the checker, and the generated `MANIFEST.txt`. If you cannot run the checker, submit your attempted work without `MANIFEST.txt`.

Rename the archive to `CHEME-5660-PS1-<your netid>.zip`, replacing the entire `<your netid>` placeholder, including the angle brackets, with your actual NetID. For example, NetID `abc123` should submit `CHEME-5660-PS1-abc123.zip`.
