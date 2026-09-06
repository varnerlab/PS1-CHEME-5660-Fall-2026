# PS1 Data

## Standard track

`standard-terms.csv` contains the bill, seven-year note, and yield-shock terms. Rates are decimal annual rates; nominal yields use semiannual compounding. These controlled classroom instruments are not current tradable quotes.

## Advanced track

`advanced-terms.csv` specifies the USD 74,000 available budget (`initial_budget`), USD 100,000 year-7 liability, USD 10,000-par lots, fixed 4.25% annual coupon, semiannual payments, horizon, and seven-year STRIP price per USD 1 par. The four sequences use only `initial_budget`. The fully funded STRIP costs `liability * seven_year_zero_price` = USD 74,967.841402 and receives the additional USD 967.841402 at time 0. No option receives a later contribution. The lot size is an assignment constraint.

The required sequences are `N7`, `N2-N5`, `N5-N2`, and seven consecutive `B1` investments. Other maturities remain in the frozen market file, but are not required comparisons. The shared valuation/repricing tasks use `standard-terms.csv`, whose fixed-yield experiment is separate from these simulated market prices.

`cir-market-scenarios.csv` contains **40 equally weighted futures**, each with **14 observations at years 0, 0.5, ..., 6.5**. At year 7 all remaining positions mature, so no new purchase price is needed.

| Column | Meaning |
|:--|:--|
| `scenario_id` | Common future identifier; use the same ID across all strategies |
| `time_years` | Current purchase/accounting date in years |
| `short_rate` | Instantaneous CIR rate state at that date; provenance, not a quoted nominal yield |
| `bill_6m_price` | Six-month zero-coupon price, USD per USD 100 par |
| `bill_1y_price` | One-year zero-coupon price, USD per USD 100 par |
| `note_2y_price`, `note_3y_price`, `note_5y_price`, `note_7y_price` | Prices of newly purchased fixed-4.25%-coupon notes with those remaining maturities, USD per USD 100 par |

All prices refer to securities purchased on that row's date. A USD 10,000-par lot costs 100 times the displayed quote. Each note pays half its annual coupon every six months; its final coupon is paid together with principal. All notes use the same fixed coupon as a controlled experiment. Main-sequence maturities must total seven years; unused quotes for securities extending beyond that horizon do not authorize an extra purchase.

The six-month bill is used by the common cash-management rule. Collect cash flows, make any scheduled main purchase first, then buy whole six-month bill lots with the remaining cash. Uninvested cash earns zero. Every purchase uses only the current row, never a future row. The initial prices are identical in all scenarios.

## CIR and the lecture notation

The generator simulates an uncertain instantaneous rate `r_t`, corresponding to the role of `g(t)` inside L1b's discounting integral. It uses the CIR pricing formula to obtain a discount curve from the current rate state and sums discounted coupon/principal payments to price notes. It does not price a security by looking at the future realized rate path.

`cir-parameters.csv` records the seed and numerical settings. The 52 Euler steps per year are simulation resolution; market observations occur every six months. The same model parameters are used for simulation and pricing, suppressing the physical-versus-risk-neutral distinction as a teaching simplification. Model paths do not establish real-world probabilities or guarantee coverage of adverse stress cases.

For a zero with quoted price `V_B` per USD 100 par, L2a's price-implied growth rate is `g_B = log(100/V_B)/T`, where `T` is remaining years. L1b's benchmark is `g_y = 2*log(1 + y/2)` under `n = 2`; it equals `g_B` only when the purchase price equals the model price at the chosen valuation yield `y`. The finite-horizon `g_B` generally differs from the instantaneous CIR rate.

Students receive the frozen prices. They do not reproduce the simulation, construct the discount curve, or parse these files.
