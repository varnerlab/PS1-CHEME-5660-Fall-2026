# Supplied Advanced-track support. Student tasks are in Advanced.jl.
"""
    affordable_lots(cash::Real, price_per_lot::Real) -> Int

Return the number of whole lots affordable without borrowing. Inputs are available
cash and the purchase price of one 10,000 USD-par lot, both in USD:

    lots = floor(cash/price_per_lot)

Assume finite cash >= 0 and price_per_lot > 0. Rounding down enforces whole lots.
"""
function affordable_lots(cash::Real, price_per_lot::Real)::Int
    return floor(Int, cash/price_per_lot);
end

"""
    uninvested_cash(cash::Real, lots::Integer, price_per_lot::Real) -> Float64

Return the cash remaining after purchasing `lots` whole lots, in USD:

    remainder = cash - lots*price_per_lot

The supplied engine passes a nonnegative, affordable lot count. Residual cash earns zero.
"""
function uninvested_cash(cash::Real, lots::Integer, price_per_lot::Real)::Float64
    return cash - lots*price_per_lot;
end

"""
    funding_ratio(terminal_value::Real, liability::Real) -> Float64

Return terminal wealth per dollar of required outlay. Both inputs are USD and
liability must be positive. The result is dimensionless:

    funding ratio = W_7/L
"""
function funding_ratio(terminal_value::Real, liability::Real)::Float64
    return terminal_value/liability;
end

"""
    shortfall(terminal_value::Real, liability::Real) -> Float64

Return the unpaid liability in USD. Both inputs are USD and liability is positive.
Exactly funded and surplus outcomes have zero shortfall:

    shortfall = max(L - W_7, 0)
"""
function shortfall(terminal_value::Real, liability::Real)::Float64
    return max(liability - terminal_value, 0.0);
end

"""
    funding_probability(terminal_values::AbstractVector, liability::Real) -> Float64

Return the fraction of a nonempty vector of USD terminal values that meets or
exceeds the positive USD liability. Count equality as funded. This sample fraction
is between 0 and 1 and is not a calibrated real-world probability.
"""
function funding_probability(terminal_values::AbstractVector,
    liability::Real)::Float64
    return count(>=(liability), terminal_values)/length(terminal_values);
end

"""
    mean_shortfall(terminal_values::AbstractVector, liability::Real) -> Float64

Return mean shortfall in USD over a nonempty vector of USD terminal values and
a positive USD liability. Include zero for each funded future when using mean.
"""
function mean_shortfall(terminal_values::AbstractVector,
    liability::Real)::Float64
    return mean(shortfall.(terminal_values, liability));
end

"""
    maximum_shortfall(terminal_values::AbstractVector, liability::Real) -> Float64

Return the largest observed shortfall in USD over a nonempty vector of USD
terminal values and a positive USD liability. All funded gives zero. Other futures
can produce a larger deficit than this observed maximum.
"""
function maximum_shortfall(terminal_values::AbstractVector,
    liability::Real)::Float64
    return maximum(shortfall.(terminal_values, liability));
end

"""
    funding_summary(terminal_values::AbstractVector, liability::Real) -> NamedTuple

Summarize a nonempty vector of final USD wealth against a positive USD liability.
Return probability_funded as a sample fraction and mean_terminal_value, mean_shortfall,
and maximum_shortfall in USD. All calculations use the supplied helpers and Statistics.
"""
function funding_summary(terminal_values::AbstractVector,
    liability::Real)::NamedTuple

    return (
        probability_funded = funding_probability(terminal_values, liability),
        mean_terminal_value = mean(terminal_values),
        mean_shortfall = mean_shortfall(terminal_values, liability),
        maximum_shortfall = maximum_shortfall(terminal_values, liability),
    );
end


const MAIN_MATURITIES = (1, 2, 3, 5, 7); # one-year bill or fixed-coupon notes, in years

"""
    investment_sequences(horizon::Integer=7) -> Vector{Vector{Int}}

Return every ordered sequence of MAIN_MATURITIES that sums to `horizon` years.
For seven years there are 50 sequences. [2, 5] and [5, 2] are different strategies.
The returned vectors are independent copies, so later edits to one do not alter
another. Throw ArgumentError when horizon <= 0. The STRIP benchmark is added
separately by `evaluate_sequences`.
"""
function investment_sequences(horizon::Integer=7)::Vector{Vector{Int}}
    horizon > 0 || throw(ArgumentError("horizon must be positive"));
    sequences = Vector{Int}[];
    # Extend a partial sequence, then undo each choice before trying the next -
    function extend_sequence(prefix, remaining)
        if remaining == 0
            push!(sequences, copy(prefix)); # preserve this completed path before changing prefix
            return;
        end
        for years ∈ MAIN_MATURITIES
            if years <= remaining
                push!(prefix, years);
                extend_sequence(prefix, remaining - years);
                pop!(prefix); # restore the caller's partial sequence
            end
        end
    end
    extend_sequence(Int[], horizon);
    return sequences;
end

"""
    sequence_label(sequence) -> String

Name a main sequence with B1 for a one-year bill and Nm for an m-year coupon note.
The prescribed six-month cash-management bills are not entries in this sequence.
"""
sequence_label(sequence)::String = join([year == 1 ? "B1" : "N$(year)" for year ∈ sequence], "-");

"""
    load_market_scenarios(path::String) -> NamedTuple

Read the supplied CSV of market prices and short rates at half-year intervals.
Scenario IDs run from 1 to S. Each scenario contains years 0, 0.5, ..., 6.5.
Return `prices`, an S-by-14-by-6 array, and `short_rates`, an S-by-14 array.
Price columns are six-month bill, one-year bill, then 2-, 3-, 5-, and 7-year notes.
Prices are USD per USD 100 par. Rates are decimal annual instantaneous rates.

Reject incorrect headers, row widths, duplicate or missing observations, invalid
indices, nonfinite rates, and nonpositive/nonfinite prices. File and numeric parsing
errors propagate. The rates document the simulation. Purchases use the price array.
"""
function load_market_scenarios(path::String)::NamedTuple
    # Read the quoted prices and their scenario/date labels -
    lines = readlines(path);
    expected = "scenario_id,time_years,short_rate,bill_6m_price,bill_1y_price,note_2y_price,note_3y_price,note_5y_price,note_7y_price";
    strip(lines[1]) == expected || throw(ArgumentError("unexpected market table header"));
    records = [split(strip(line), ',') for line ∈ lines[2:end] if !isempty(strip(line))];
    count = maximum(parse(Int, row[1]) for row ∈ records);
    prices = fill(NaN, count, 14, 6); # scenario, purchase date 0:0.5:6.5, security
    rates = fill(NaN, count, 14); # instantaneous short rates, per year
    seen = falses(count, 14); # detect duplicate and missing scenario/date pairs
    # Map each CSV row into its scenario and half-year array position -
    for row ∈ records
        length(row) == 9 || throw(ArgumentError("invalid market row"));
        scenario = parse(Int, row[1]);
        time = parse(Float64, row[2]);
        step = Int(2*time) + 1; # half-year time index mapped to a Julia position
        1 <= scenario <= count && 1 <= step <= 14 || throw(ArgumentError("invalid market index"));
        seen[scenario, step] && throw(ArgumentError("duplicate market observation"));
        prices[scenario, step, :] .= parse.(Float64, row[4:9]);
        rates[scenario, step] = parse(Float64, row[3]);
        seen[scenario, step] = true;
    end
    all(seen) && all(isfinite, prices) && all(>(0), prices) && all(isfinite, rates) ||
        throw(ArgumentError("incomplete or invalid market table"));
    return (prices=prices, short_rates=rates);
end

"""
    purchase_lots(cash::Real, price_per_lot::Real) -> NamedTuple

Apply the supplied whole-lot rule to USD inputs.
Return `(lots, cash)`, with an integer lot count and the remaining USD balance.
Assume a finite nonnegative budget and a finite positive lot price.

Throw ArgumentError for an unaffordable/negative lot count or a nonfinite/negative
cash remainder. Allow at most 1e-7 USD of negative floating-point roundoff, clamping
that remainder to zero. Invalid purchase inputs are rejected.
"""
function purchase_lots(cash::Real, price_per_lot::Real)::NamedTuple
    # Compute the whole-lot purchase and check the cash balance -
    lots = affordable_lots(cash, price_per_lot);
    lots >= 0 && lots*price_per_lot <= cash + 1e-7 || throw(ArgumentError("purchase exceeds available cash"));
    remainder = uninvested_cash(cash, lots, price_per_lot);
    isfinite(remainder) && remainder >= -1e-7 || throw(ArgumentError("invalid residual cash"));
    return (lots=lots, cash=max(remainder, 0.0));
end

"""
    simulate_sequence(sequence, market, scenario, terms; keep_ledger=false) -> NamedTuple

Evaluate one fixed sequence under one scenario from `load_market_scenarios`.
`sequence` contains holding times in years. `scenario` is a 1-based scenario ID.
`terms` supplies liability, lot_par, coupon_rate, compounding_frequency,
horizon_years, and initial_budget from advanced-terms.csv.

Start with terms.initial_budget USD. At every half-year date, collect
coupons, maturing principal, and prior six-month bill proceeds. Make a scheduled
sequence purchase first, then buy six-month bill lots with the remaining cash.
Residual cash earns zero. Even a zero-lot purchase keeps the original schedule.
Prices use only the current date's row. At year 7, collect payments and stop buying.

Return `terminal_value` in USD and `ledger`. With keep_ledger=true, the ledger has
one row per date, including time 0 and year 7 (15 rows). Each row records opening
and closing cash, receipts, lot counts, purchase costs, and par held after trading.
All money/par fields are USD. Otherwise the ledger is empty.
Throw ArgumentError for an invalid sequence. Market-index and calculation
errors propagate to `evaluate_sequences`.
"""
function simulate_sequence(sequence::AbstractVector{<:Integer}, market::NamedTuple,
    scenario::Integer, terms::NamedTuple; keep_ledger::Bool=false)::NamedTuple
    horizon = Int(terms.horizon_years);
    sum(sequence) == horizon && all(year -> year ∈ MAIN_MATURITIES, sequence) ||
        throw(ArgumentError("sequence must use allowed maturities and total the horizon"));
    # Initialize the budget, scheduled holding, and six-month cash investment -
    cash = terms.initial_budget; # available budget for every sequence, USD
    isfinite(cash) && cash >= 0 || throw(ArgumentError("initial budget must be finite and nonnegative"));
    core_coupon = 0.0; # fixed USD coupon per payment on the current holding
    core_par = 0.0; # total par held in the current sequence investment, USD
    core_years = 0; # original holding time of the current sequence investment
    core_end = 0; # maturity date measured in half-year steps
    position = 1; # next entry to buy in the fixed sequence
    bill_par = 0.0; # six-month cash-management bill maturing on the next date
    ledger = NamedTuple[];

    for step ∈ 0:2*horizon
        # Collect every receipt due before making a new purchase -
        opening_cash = cash;
        bill_receipt = step > 0 ? bill_par : 0.0;
        coupon = step > 0 && core_years > 1 ?
            core_coupon : 0.0;
        principal = step > 0 && step == core_end ? core_par : 0.0;
        cash += bill_receipt + coupon + principal;
        bill_par = 0.0; # the preceding six-month bill has matured
        if step > 0 && step == core_end
            core_par = 0.0;
            position += 1;
        end

        # Choose purchases from the predeclared sequence and this date's prices -
        main_lots = 0;
        sweep_lots = 0;
        main_cost = 0.0;
        sweep_cost = 0.0;
        if step < 2*horizon
            if step == core_end
                core_years = sequence[position];
                column = findfirst(==(core_years), MAIN_MATURITIES) + 1; # column 1 is the six-month bill
                unit_price = market.prices[scenario, step+1, column]*terms.lot_par/100;
                purchase = purchase_lots(cash, unit_price);
                main_lots = purchase.lots;
                main_cost = main_lots*unit_price;
                cash = purchase.cash;
                core_par = main_lots*terms.lot_par;
                # Decompose the actual held note using the package's public STRIPS API.
                # Coupon strip face values are promised USD receipts, not market prices.
                core_coupon = 0.0;
                if core_years > 1
                    held_note = build(MyUSTreasuryCouponSecurityModel, (
                        par=core_par, coupon=terms.coupon_rate, T=Float64(core_years),
                        λ=Int(terms.compounding_frequency),
                    ));
                    core_coupon = VLQuantitativeFinancePackage.strip(held_note)[1].par;
                end
                core_end = step + 2*core_years; # keep this maturity date even if no lot was affordable
            end
            # Reinvest coupons and remaining cash until the next half-year date -
            bill_price = market.prices[scenario, step+1, 1]*terms.lot_par/100; # USD per lot
            purchase = purchase_lots(cash, bill_price);
            sweep_lots = purchase.lots;
            sweep_cost = sweep_lots*bill_price;
            cash = purchase.cash;
            bill_par = sweep_lots*terms.lot_par;
        end
        if keep_ledger
            # Record receipts, spending, and balances for this date -
            push!(ledger, (time_years=step/2, opening_cash=opening_cash, coupon=coupon,
                main_principal=principal, bill_principal=bill_receipt, main_lots=main_lots,
                main_cost=main_cost, cash_bill_lots=sweep_lots, cash_bill_cost=sweep_cost,
                closing_cash=cash, main_par_held=core_par, cash_bill_par_held=bill_par));
        end
    end
    return (terminal_value=cash, ledger=ledger);
end

"""
    strip_funding(terms::NamedTuple) -> NamedTuple

Compute the initial cost of STRIP lots sufficient to pay the liability and the
additional USD contribution required beyond `initial_budget`. `seven_year_zero_price`
is the supplied price per USD 1 par. The liability must be a positive whole number
of `lot_par` lots. Return `lots`, `par`, `initial_capital`, and
`additional_contribution`. Invalid amounts raise ArgumentError.
"""
function strip_funding(terms::NamedTuple)::NamedTuple
    all(x -> isfinite(x) && x > 0,
        (terms.liability, terms.lot_par, terms.seven_year_zero_price)) ||
        throw(ArgumentError("liability, lot size, and STRIP price must be positive"));
    isfinite(terms.initial_budget) && terms.initial_budget >= 0 ||
        throw(ArgumentError("initial budget must be finite and nonnegative"));
    isinteger(terms.liability/terms.lot_par) ||
        throw(ArgumentError("liability must be a whole number of STRIP lots"));
    capital = terms.liability*terms.seven_year_zero_price;
    return (lots=Int(terms.liability/terms.lot_par), par=terms.liability,
        initial_capital=capital, additional_contribution=max(capital-terms.initial_budget, 0.0));
end

"""
    evaluate_sequences(market, terms; sequences) -> Vector{NamedTuple}

Evaluate the supplied sequence vectors at `terms.initial_budget`, adding a fully
funded STRIP alternative. `sequences` must be a nonempty collection of distinct
holding-time vectors. Each must total the horizon using MAIN_MATURITIES.
Invalid choices raise ArgumentError. Market inputs follow `load_market_scenarios`.

The STRIP receives enough additional capital at time zero to purchase the promised
liability payment. Each sequence receives only the available budget. Every row
therefore records `initial_capital` and `additional_contribution` in USD explicitly.
The STRIP's empty sequence denotes a single principal payment at the horizon.

Rows also contain `label`, `sequence`, per-scenario `terminal_values` in USD,
`funding_ratios`, `shortfalls` in USD, `summary`, and `detail`. The summary reports
the funded fraction, mean terminal wealth, mean shortfall including zeros, and
maximum observed shortfall. Calculation errors produce an unavailable row with a
nonempty detail. No strategy is selected based on knowledge of the realized future.
"""
function evaluate_sequences(market::NamedTuple, terms::NamedTuple;
    sequences::AbstractVector)::Vector{NamedTuple}
    horizon = Int(terms.horizon_years);
    !isempty(sequences) && length(unique(sequences)) == length(sequences) ||
        throw(ArgumentError("provide distinct, nonempty strategy choices"));
    all(s -> !isempty(s) && all(y -> y isa Integer && y in MAIN_MATURITIES, s) &&
        sum(s) == horizon, sequences) || throw(ArgumentError("invalid strategy holding times"));
    strip_plan = strip_funding(terms);
    count = size(market.prices, 1);
    rows = NamedTuple[];
    # Apply each strategy to the same scenario IDs; only STRIP receives extra capital.
    for sequence in vcat([Int[]], sequences)
        is_strip = isempty(sequence);
        label = is_strip ? "STRIP7" : sequence_label(sequence);
        capital = is_strip ? strip_plan.initial_capital : terms.initial_budget;
        contribution = is_strip ? strip_plan.additional_contribution : 0.0;
        try
            values = is_strip ? fill(terms.liability, count) :
                [simulate_sequence(sequence, market, s, terms).terminal_value for s in 1:count];
            summary = funding_summary(values, terms.liability);
            push!(rows, (label=label, sequence=copy(sequence), initial_capital=capital,
                additional_contribution=contribution, terminal_values=values,
                funding_ratios=funding_ratio.(values, terms.liability),
                shortfalls=shortfall.(values, terms.liability), summary=summary, detail=""));
        catch caught
            push!(rows, (label=label, sequence=copy(sequence), initial_capital=capital,
                additional_contribution=contribution, terminal_values=Float64[],
                funding_ratios=Float64[], shortfalls=Float64[], summary=nothing,
                detail=sprint(showerror, caught)));
        end
    end
    return rows;
end
