# PS1: Treasury Valuation, Interest-Rate Risk, and Funding a Future Obligation

In Problem Set 1 (PS1), you will value Treasury cash flows and analyze interest-rate risk using the time-value-of-money, Treasury pricing, and sensitivity tools from lecture.

Choose one track. **Standard** examines how Treasury prices respond to a change in yield. **Advanced** includes those valuation tasks and adds a decision about funding a payment due in seven years.

After completing your chosen track, you should be able to interpret interest rates, connect Treasury cash flows to risk, and use your results to explain what they say about funding and interest-rate risk.

## Logistics

- **Deadline:** Upload your ZIP to Canvas by **September 20, 2026 at 11:59 PM ET**.
- **Score:** Your selected track is graded out of 4 points, and an accepted 4 on Advanced also earns one Magic Point.
- **Submit something:** A readable ZIP with attempted work by the deadline, even if tests fail, keeps you eligible for unlimited revisions through the end of the semester.
- **Independent work:** You may discuss ideas and use documentation, AI tools, and internet resources, but the work you submit must be your own and you must be able to explain it.

See [RUBRIC.md](RUBRIC.md) for the full grading and revision policies.

## Getting started

This assignment is supported with **Julia 1.12.7** and uses `VLQuantitativeFinancePackage`, the same package used in the lecture examples.

1. Open the [PS1 Releases page](https://github.com/varnerlab/PS1-CHEME-5660-Fall-2026/releases) and select the release announced on Canvas.
2. Under **Assets**, download **Source code (zip)** and extract the archive. In VS Code, choose **File → Open Folder** and select the extracted PS1 folder containing `README.md`, `Project.toml`, and `check_submission.jl`.
3. In VS Code, choose **Terminal → New Terminal**. From the extracted PS1 folder containing `Project.toml`, run this setup command once to install the recorded package versions:

   ```text
   julia --project=. --startup-file=no -e 'using Pkg; Pkg.instantiate()'
   ```

   The first setup needs an internet connection and may take several minutes.
4. Set `TRACK.txt` to exactly `standard` or `advanced`.

## Complete your work

Edit the two files for your chosen track:

| Track | Code | Discussion questions |
|:--|:--|:--|
| Standard | [src/Standard.jl](src/Standard.jl) | [responses/Standard.md](responses/Standard.md) |
| Advanced | [src/Advanced.jl](src/Advanced.jl) | [responses/Advanced.md](responses/Advanced.md) |

Complete the `TODO` items in your source file using the instructions above each function. Replace the starter error statements with your code, remove completed `TODO` comments, and keep the function docstrings. Put any additional helpers inside `src`. Leave the supplied support code, data, tests, reports, and checker unchanged.

__Use your results to answer the three discussion questions__. Answer each question in a short paragraph, using a compact table for the reported values where useful. Keep the `<!-- answer-N:start -->` and `<!-- answer-N:end -->` markers around each answer. Report monetary values in USD and rates as percentages.

### Standard track

Use the package calls from the lecture examples to price a six-month Treasury bill and a seven-year coupon note. Then reprice a copy of the note after its yield rises by **50 basis points**.

* __Example__: One basis point is 0.01 percentage points, so 50 basis points is 0.50 percentage points. In this assignment, the note's yield increases from **4.60% to 5.10%**. The note's coupon rate stays at 4.25%.

Complete three tasks in `src/Standard.jl`: build and price the bill, build and price the note, and reprice the note at the higher yield. Use `build(...)`, `DiscreteCompoundingModel()`, and `deepcopy(...)` as demonstrated in L2a and L2b. The docstrings list the model fields and supplied inputs. Follow the [bill pricing](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187/lectures/week-2/L2a/CHEME-5660-L2a-TBills-Pricing-Fall-2026-WorkedExample.ipynb), [note pricing](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187/lectures/week-2/L2a/CHEME-5660-L2a-NotesBonds-Pricing-Fall-2026-WorkedExample.ipynb), and [repricing](https://github.com/varnerlab/CHEME-5660-CourseRepository-Fall-2026/blob/e28114ac805c9f9c87f3e6fc4cc3c4ec7b5ec187/lectures/week-2/L2b/CHEME-5660-L2b-Example-Treasury-Duration-Convexity-Fall-2026.ipynb) examples.

The checker reports the rates, duration, convexity, and estimated price change from your priced models. Compare that estimate with the exact repriced value. In your discussion answers, report exact price minus estimated price in USD per USD 100 par. Show enough precision to make the small difference visible, for example four decimal places or scientific notation.

The security terms are in [data/standard-terms.csv](data/standard-terms.csv).

### Advanced track

A firm has **USD 74,000 today** and must pay **USD 100,000 at the end of year 7**. Its budget is below the cost of a Treasury investment that secures the full payment. Should it invest the available money and accept a possible shortfall, or contribute more today to secure the obligation?

First, complete the same three package-based valuation and repricing tasks described in the Standard track. These tasks are included in `src/Advanced.jl`. Then complete `compare_strategies` by passing the four choices below to the supplied `evaluate_sequences` function. The docstring shows the call and the strategy vectors. Complete only `src/Advanced.jl` and `responses/Advanced.md`; Advanced includes its own valuation discussion question.

| Strategy | What the firm buys with USD 74,000 |
|:--|:--|
| `N7` | A seven-year note held to maturity |
| `N2-N5` | A two-year note, then a five-year note |
| `N5-N2` | A five-year note, then a two-year note |
| `B1-B1-B1-B1-B1-B1-B1` | A one-year bill, replaced at maturity each year for seven years |

Each sequence is chosen before the future is known. The firm holds each main security to maturity, then uses the available cash to buy the next security. Order matters because purchases and coupon payments occur at different times.

All purchases use whole lots of **USD 10,000 par**. Notes have a fixed **4.25% annual coupon**, paying **USD 212.50 per lot every six months**. The coupon stays fixed while market prices change. Coupons and leftover cash are invested in whole lots of six-month bills, with any remaining cash held at zero interest. The supplied code handles these purchases, payments, and reinvestments.

**Compare funding risk with the cost of certainty**

The comparison also includes `STRIP7`: a seven-year principal STRIP paying exactly USD 100,000 at year 7. [STRIPS](https://www.treasurydirect.gov/marketable-securities/strips/) stands for **Separate Trading of Registered Interest and Principal of Securities**. A principal STRIP is the principal payment traded separately from the coupons. It makes one payment at maturity.

Buying ten STRIP lots costs **USD 74,967.84**, requiring an **additional USD 967.84 today**. This option receives more initial capital than the four sequences. The report displays that contribution explicitly. The firm is considering this contribution as an alternative to accepting funding risk.

The supplied data describe **40 possible futures** for interest rates and security prices. Every sequence uses the same futures, and each purchase uses only the price available at that time. Use these supplied prices for the funding comparison. The initial valuation and 50-basis-point repricing exercise uses the separate terms in `data/standard-terms.csv`.

For each option, report the funded count out of 40, mean final wealth, mean shortfall, and maximum shortfall. A future is funded when final wealth is at least USD 100,000. Mean shortfall includes zero for funded futures. Your discussion questions ask you to explain the valuation results, compare funding frequency with deficit size, and recommend whether to accept funding risk or contribute the additional capital.

The futures were generated with the **CIR interest-rate model**. The simulation, security prices, reinvestment calculations, and summary statistics are supplied. You do not need to implement or derive the CIR model. These are simulated examples, and other market conditions could produce larger shortfalls. The [data notes](data/README.md) explain the inputs.

**Reference: how cash is reinvested**

At time 0 and every six months through year 6.5, the supplied code:

1. Collects coupons, maturing principal, and cash carried forward.
2. Buys as many whole lots of the scheduled main security as the available cash allows, at time 0 or when the previous main security matures.
3. Invests the remaining cash in as many whole six-month bill lots as it can afford, carrying any leftover cash at zero interest.

If no lot is affordable, the code buys zero lots and keeps the scheduled purchase dates. At year 7, it collects all final payments and stops investing. The fully funded STRIP is held directly to year 7. All securities make their promised payments. There is no borrowing, early sale, tax, transaction cost, or later contribution. Only the fully funded STRIP option receives the stated additional contribution at time 0.

## Check and submit

In VS Code, choose **Terminal → New Terminal**. Run this command from the extracted PS1 folder containing `Project.toml` and `check_submission.jl`:

```text
julia --project=. --startup-file=no check_submission.jl
```

The checker runs the tests, displays your results, and creates `MANIFEST.txt`. **Tests are expected to fail until you complete the starter code.** Calculations that cannot yet run appear as `UNAVAILABLE`. To run only the tests, use `testme_standard.jl` or `testme_advanced.jl` in place of `check_submission.jl` in the command above.

For Advanced, the checker also saves `results/advanced-strategies.csv` with the strategy comparison and `results/advanced-scenario-outcomes.csv` with results for each future. Matching `scenario_id` values identify the same future across strategies.

To earn a 4, all tests must pass and the teaching team must accept your code, documentation, and discussion answers. The checker flags missing docstrings and unfinished answers, but the teaching team reviews their substance. Passing all tests gives **pending completion review** until that review is finished. The score table is in [RUBRIC.md](RUBRIC.md).

When you are ready to submit:

1. Run the checker again, then ZIP the entire extracted PS1 folder containing `README.md`, `Project.toml`, `TRACK.txt`, `src`, `responses`, `data`, and `MANIFEST.txt`. In macOS Finder, right-click the extracted PS1 folder and choose **Compress**. In Windows File Explorer, right-click the extracted PS1 folder and choose **Send to → Compressed (zipped) folder** (under **Show more options** on Windows 11).
2. Name the ZIP `CHEME-5660-PS1-<your netid>.zip`, replacing `<your netid>` with your NetID. For example, `CHEME-5660-PS1-abc123.zip`.
3. Upload the ZIP to the PS1 assignment on Canvas. The checker does not upload it for you.

Submit your attempted work by the deadline even if some checks fail or cannot run. For an eligible revision, repeat these steps and use **New Attempt** on the same Canvas assignment.
