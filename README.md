# PS1: Fund a Known Future Outlay with U.S. Treasury Securities

Problem Set 1 asks you to value Treasury cash flows and reason about interest-rate risk using the time-value-of-money tools from L1b and the Treasury pricing and yield-curve tools from week 2. This is a finance assignment implemented in a small amount of Julia; it is not a Julia programming assignment.

## Learning objectives

After completing your chosen track, you should be able to:

1. Convert Treasury prices, yields, growth rates, and discount factors under a stated convention.
2. Value dated Treasury cash flows and connect their timing to interest-rate exposure.
3. Evaluate whether a Treasury strategy funds a known future cash outlay under the assumptions of the model.

## Logistics

- **Release:** Sunday, September 6, 2026.
- **Due:** Sunday, September 20, 2026 at 11:59 PM ET as a ZIP archive uploaded to Canvas.
- **Choose one track:** Complete either the Standard track or the Advanced track. Both tracks receive an ordinary score on the course's 0-to-4 scale.
- **Advanced Magic Point:** A score of 4 on the Advanced track earns one Magic Point in addition to the PS1 score. Scores below 4 do not earn the Magic Point.
- **Revisions:** You must make a qualifying submission by the deadline to enter the revision process. A missing submission receives a Frozen Zero and cannot be raised through revision or Magic Points.

## This is not a Julia programming assignment

The supplied code reads the data, constructs the note's cash-flow schedule, organizes the CIR scenarios, and runs the tests. You complete only short expressions that translate displayed financial equations into Julia.

You do **not** need to:

- define a custom type;
- parse a CSV file;
- construct a coupon schedule;
- write a scenario loop;
- implement or calibrate CIR; or
- create a notebook.

Edit only the source and finance-response files for your chosen track:

- Standard: `src/Standard.jl` and `responses/Standard.md`
- Advanced: `src/Advanced.jl` and `responses/Advanced.md`

Do not edit `src/Support.jl`, the data, or the public tests.

## Getting started

From the problem-set directory, instantiate the supplied Julia environment:

```text
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Put exactly one word in `TRACK.txt`:

```text
standard
```

or

```text
advanced
```

Run the tests for your selected track:

```text
julia --project=. testme_standard.jl
```

or

```text
julia --project=. testme_advanced.jl
```

Every public test is evaluated independently. This allows a partially completed solution to receive credit even when a different function produces an error.

## The common setting

A firm knows that it must make a fixed payment seven periods from today. Treasury securities can be used either to match the payment date or to reinvest through a sequence of shorter positions. The two tracks examine this setting at different levels.

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

at the end of period 7. Compare two strategies that use the same initial capital.

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

Then summarize the probability of full funding, mean terminal value, mean shortfall, and maximum shortfall.

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

The score is determined from the complete collection of individual public tests, followed by a documentation and task-completion check:

| Score | Condition |
|:--:|:--|
| 0 | You submitted something, but the tests did not run or every test failed. |
| 1 | The tests ran and at least one succeeded, but no more than half succeeded. |
| 2 | The tests ran and strictly more than half succeeded, but at least one failed. |
| 3 | Every test succeeded, but documentation or another required task was incomplete. |
| 4 | Every test succeeded, the required functions remained documented, and all tasks—including the selected finance response—were completed. |

For clarity, “most tests succeeded” means strictly more than half: at least 7 of 13 Standard tests or at least 9 of 16 Advanced tests. Passing all numerical tests is necessary for a 3 or 4. The teaching team reviews the quality of the documentation and finance responses before assigning a final score of 4.

A missing submission is different from a rubric score of 0: it becomes a Frozen Zero and is not eligible for revision or Magic Points. A partial solution is therefore worth submitting.

An Advanced-track score of 4 earns one Magic Point. No other Advanced-track score earns the bonus.

## Submitting your work

When you are done, or as far as you got, run:

```text
julia --project=. --startup-file=no submit.jl
```

The script reads `TRACK.txt`, evaluates every public test, checks the selected response file and function documentation, reports a provisional rubric score, and writes `MANIFEST.txt`. Then:

1. Zip the complete problem-set folder.
2. Rename the archive `PS1-<your netid>.zip`.
3. Upload it to the PS1 assignment on Canvas.
