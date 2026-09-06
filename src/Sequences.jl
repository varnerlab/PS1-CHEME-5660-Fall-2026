# Supplied Advanced-track machinery. Students implement only the formulas in Advanced.jl.
const MAIN_MATURITIES = (1, 2, 3, 5, 7); # one-year bill or fixed-coupon notes, in years

"""
    investment_sequences(horizon::Integer=7) -> Vector{Vector{Int}}

Enumerate every ordered sequence of allowed maturities that totals `horizon` years.
The order of purchases is fixed before a future rate path is observed.
"""
function investment_sequences(horizon::Integer=7)::Vector{Vector{Int}}
    horizon > 0 || throw(ArgumentError("horizon must be positive"));
    sequences = Vector{Int}[];
    function extend_sequence(prefix, remaining)
        if remaining == 0
            push!(sequences, copy(prefix));
            return;
        end
        for years ∈ MAIN_MATURITIES
            if years <= remaining
                push!(prefix, years);
                extend_sequence(prefix, remaining - years);
                pop!(prefix);
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

Read the supplied half-year market table. Prices are USD per 100 USD par; the six
columns are B0.5, B1, N2, N3, N5, N7. Reject missing or duplicate observations.
"""
function load_market_scenarios(path::String)::NamedTuple
    lines = readlines(path);
    expected = "scenario_id,time_years,short_rate,bill_6m_price,bill_1y_price,note_2y_price,note_3y_price,note_5y_price,note_7y_price";
    strip(lines[1]) == expected || throw(ArgumentError("unexpected market table header"));
    records = [split(strip(line), ',') for line ∈ lines[2:end] if !isempty(strip(line))];
    count = maximum(parse(Int, row[1]) for row ∈ records);
    prices = fill(NaN, count, 14, 6); # scenario, purchase date 0:0.5:6.5, security
    rates = fill(NaN, count, 14);
    seen = falses(count, 14);
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
    purchase_lots(cash, price_per_lot) -> NamedTuple

Apply the student's lot and cash formulas. Check the no-borrowing constraint and
remove only tiny negative roundoff (at most 1e-7 USD) from the residual cash balance.
"""
function purchase_lots(cash::Real, price_per_lot::Real)::NamedTuple
    lots = affordable_lots(cash, price_per_lot);
    lots >= 0 && lots*price_per_lot <= cash + 1e-7 || throw(ArgumentError("purchase exceeds available cash"));
    remainder = uninvested_cash(cash, lots, price_per_lot);
    isfinite(remainder) && remainder >= -1e-7 || throw(ArgumentError("invalid residual cash"));
    return (lots=lots, cash=max(remainder, 0.0));
end

"""
    simulate_sequence(sequence, market, scenario, terms; keep_ledger=false) -> NamedTuple

Hold each main security to maturity and buy the next using only current-date prices.
At every half-year date, first collect coupons and maturing principal. Buy the next
main security when due, then use remaining cash for whole six-month bill lots.
Residual cash earns zero. At year 7, collect all payments and stop purchasing.
Return terminal wealth and, optionally, the dated cash ledger. Prices are per 100 par;
all ledger cash values and principal amounts are USD. No future market row is read.
"""
function simulate_sequence(sequence::AbstractVector{<:Integer}, market::NamedTuple,
    scenario::Integer, terms::NamedTuple; keep_ledger::Bool=false)::NamedTuple
    horizon = Int(terms.horizon_years);
    sum(sequence) == horizon && all(year -> year ∈ MAIN_MATURITIES, sequence) ||
        throw(ArgumentError("sequence must use allowed maturities and total the horizon"));
    cash = terms.liability*terms.seven_year_zero_price;
    core_par = 0.0;
    core_years = 0;
    core_end = 0; # maturity date measured in half-year steps
    position = 1;
    bill_par = 0.0; # six-month cash-management bill maturing on the next date
    ledger = NamedTuple[];

    for step ∈ 0:2*horizon
        opening_cash = cash;
        bill_receipt = step > 0 ? bill_par : 0.0;
        coupon = step > 0 && core_years > 1 ?
            coupon_payment(core_par, terms.coupon_rate, Int(terms.compounding_frequency)) : 0.0;
        principal = step > 0 && step == core_end ? core_par : 0.0;
        cash += bill_receipt + coupon + principal;
        bill_par = 0.0;
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
                column = findfirst(==(core_years), MAIN_MATURITIES) + 1;
                unit_price = market.prices[scenario, step+1, column]*terms.lot_par/100;
                purchase = purchase_lots(cash, unit_price);
                main_lots = purchase.lots;
                main_cost = main_lots*unit_price;
                cash = purchase.cash;
                core_par = main_lots*terms.lot_par;
                core_end = step + 2*core_years;
            end
            bill_price = market.prices[scenario, step+1, 1]*terms.lot_par/100;
            purchase = purchase_lots(cash, bill_price);
            sweep_lots = purchase.lots;
            sweep_cost = sweep_lots*bill_price;
            cash = purchase.cash;
            bill_par = sweep_lots*terms.lot_par;
        end
        if keep_ledger
            push!(ledger, (time_years=step/2, opening_cash=opening_cash, coupon=coupon,
                main_principal=principal, bill_principal=bill_receipt, main_lots=main_lots,
                main_cost=main_cost, cash_bill_lots=sweep_lots, cash_bill_cost=sweep_cost,
                closing_cash=cash, main_par_held=core_par, cash_bill_par_held=bill_par));
        end
    end
    return (terminal_value=cash, ledger=ledger);
end

"""
    evaluate_sequences(market, terms) -> Vector{NamedTuple}

Evaluate all fixed sequences across the same futures. An unfinished student formula
marks the affected strategy unavailable without halting the remaining strategies.
The STRIP benchmark buys liability/lot_par lots and holds them to year 7.
"""
function evaluate_sequences(market::NamedTuple, terms::NamedTuple)::Vector{NamedTuple}
    count = size(market.prices, 1);
    isinteger(terms.liability/terms.lot_par) || throw(ArgumentError("liability must be a whole number of STRIP lots"));
    rows = NamedTuple[];
    choices = vcat([Int[]], investment_sequences(Int(terms.horizon_years)));
    for sequence ∈ choices
        label = isempty(sequence) ? "STRIP7" : sequence_label(sequence);
        try
            values = isempty(sequence) ? fill(terms.liability, count) :
                [simulate_sequence(sequence, market, s, terms).terminal_value for s ∈ 1:count];
            summary = funding_summary(values, terms.liability);
            ratios = [funding_ratio(value, terms.liability) for value ∈ values];
            deficits = [shortfall(value, terms.liability) for value ∈ values];
            push!(rows, (label=label, sequence=sequence, terminal_values=values,
                funding_ratios=ratios, shortfalls=deficits, summary=summary, detail=""));
        catch caught
            push!(rows, (label=label, sequence=sequence, terminal_values=Float64[],
                funding_ratios=Float64[], shortfalls=Float64[],
                summary=nothing, detail=sprint(showerror, caught)));
        end
    end
    return rows;
end
