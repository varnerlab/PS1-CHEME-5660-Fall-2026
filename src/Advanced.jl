# PS1 Advanced Track
#
# Use the package calls from the L2a Treasury pricing examples and the L2b
# sensitivity example. Complete the valuation tasks and the funding comparison below.

"""
    build_bill(terms::NamedTuple) -> MyUSTreasuryZeroCouponBondModel

Build and price the bill using `build` and `DiscreteCompoundingModel` from
VLQuantitativeFinancePackage. Return the priced model, including its `price` field.

Follow L2a's "Pricing Zero-Coupon Treasury Bills Using NPV", Task 1. Use these
entries from the supplied `terms` record to populate the package's model fields:

| Model field | Supplied value | Meaning |
|:--|:--|:--|
| `par` | `terms.bill_par` | maturity payment in USD |
| `rate` | `terms.bill_yield` | nominal annual yield as a decimal |
| `T` | `terms.bill_maturity` | years to maturity |
| `n` | `Int(terms.bill_compounding_frequency)` | compounding periods per year |

Call `build(MyUSTreasuryZeroCouponBondModel, (...))` with these named fields,
then pipe the model into `DiscreteCompoundingModel()` with `|>` and return it.
The supplied yield already uses the nominal-yield convention needed by the model.
"""
function build_bill(terms::NamedTuple)::MyUSTreasuryZeroCouponBondModel
    # TODO: Build the bill from the supplied terms, price it, and return the model.
    throw("build_bill is not implemented yet");
end

"""
    build_note(terms::NamedTuple) -> MyUSTreasuryCouponSecurityModel

Build and price the note using the same package calls as L2a's "The Pricing of
United States Treasury Coupon-Bearing Notes and Bonds", Task 1, and L2b's
"Sensitivity of Coupon Treasury Notes and Bonds", Task 1.

| Model field | Supplied value | Meaning |
|:--|:--|:--|
| `par` | `terms.note_par` | maturity principal in USD |
| `rate` | `terms.note_yield` | nominal annual yield as a decimal |
| `coupon` | `terms.note_coupon_rate` | fixed annual coupon rate as a decimal |
| `T` | `terms.note_maturity` | years to maturity |
| `λ` | `Int(terms.note_compounding_frequency)` | coupon payments per year |

Call `build(MyUSTreasuryCouponSecurityModel, (...))` with these named fields,
then pipe the model into `DiscreteCompoundingModel()` with `|>` and return it.
Julia's `λ` can be entered by typing `\\lambda` and pressing Tab.
The package constructs the cash-flow schedule and computes the price.
"""
function build_note(terms::NamedTuple)::MyUSTreasuryCouponSecurityModel
    # TODO: Build the note from the supplied terms, price it, and return the model.
    throw("build_note is not implemented yet");
end

"""
    reprice_note(note::MyUSTreasuryCouponSecurityModel, yield_change::Real)
        -> MyUSTreasuryCouponSecurityModel

Return a repriced copy of `note` after adding `yield_change` to its nominal annual
yield. Follow the L2b sensitivity example's use of `deepcopy`, a changed `rate`,
and the discrete-compounding pricing call.

Create a copy with `deepcopy(note)`, add `yield_change` to the copy's `rate`,
then pipe the copy into `DiscreteCompoundingModel()` and return it.
Keep the original model unchanged so its price remains available for comparison.
The coupon rate, par, maturity, and coupon frequency stay fixed.

The supplied change is an addition of 0.005: 4.60% becomes 5.10%.
All inputs use decimal annual rates. The return value is the complete priced model.
"""
function reprice_note(note::MyUSTreasuryCouponSecurityModel,
    yield_change::Real)::MyUSTreasuryCouponSecurityModel
    # TODO: Copy the note, add the yield change, reprice the copy, and return it.
    throw("reprice_note is not implemented yet");
end

"""
    compare_strategies(market::NamedTuple, terms::NamedTuple) -> Vector{NamedTuple}

Compare four investments using the supplied `evaluate_sequences` function.
`market` is the supplied set of 40 price futures. `terms` contains the available
budget, liability, lot size, coupon terms, horizon, and STRIP price from
`data/advanced-terms.csv`. File loading is supplied by the checker.

Represent the four strategies as vectors of holding times in years:
`[7]`, `[2, 5]`, `[5, 2]`, and `[1, 1, 1, 1, 1, 1, 1]`.
Call `evaluate_sequences(market, terms; sequences=choices)`, where `choices`
contains those four vectors, and return its result unchanged.

The supplied function handles purchases, coupon reinvestment, and funding
statistics. It also adds `STRIP7`, which requires an additional contribution
today. Each row reports `initial_capital` and `additional_contribution` in USD,
40 `terminal_values` in USD, and a `summary` containing `probability_funded`,
`mean_terminal_value`, `mean_shortfall`, and `maximum_shortfall`.
The funded fraction counts equality as funded. Mean shortfall includes zeros
for funded futures. A nonempty `detail` field describes an unavailable result.

Use the results to explain the funding tradeoff in responses/Advanced.md.
The supplied futures are a common comparison sample, not known future prices
or calibrated probabilities. No simulation or statistical routines need to be
implemented here. Invalid terms or sequences are reported by the supplied helper.
"""
function compare_strategies(market::NamedTuple, terms::NamedTuple)::Vector{NamedTuple}
    # TODO: Pass the four strategy vectors to evaluate_sequences and return its results.
    throw("compare_strategies is not implemented yet");
end
