using Printf # labeled numerical output with enough precision to compare repricing errors

"""
    standard_report_rows() -> Vector{NamedTuple}

Build labeled calculations from the student's Standard functions and supplied terms.
Each row is evaluated separately so a partial solution can still display useful results.
"""
function standard_report_rows()::Vector{NamedTuple}
    # Load the security terms and supplied payment schedule -
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "standard-terms.csv"));
    schedule = note_cashflows(terms);
    bill_n = Int(terms.bill_compounding_frequency);
    note_n = Int(terms.note_compounding_frequency);

    # Connect the student's formulas into the financial calculation -
    discounts = () -> discount_factors(terms.note_yield, note_n, schedule.payment_times);
    price = () -> present_value(schedule.cashflows, discounts());
    macaulay = () -> macaulay_duration(schedule.payment_times, schedule.cashflows, discounts(), price());
    modified = () -> modified_duration(macaulay(), terms.note_yield, note_n);
    curvature = () -> convexity(schedule.period_indices, schedule.cashflows, discounts(),
        price(), terms.note_yield, note_n);
    fraction = () -> price_change_fraction(modified(), curvature(), terms.yield_change);
    exact = () -> present_value(schedule.cashflows, discount_factors(
        terms.note_yield + terms.yield_change, note_n, schedule.payment_times));
    estimate = () -> price()*(1 + fraction());

    return [
        (label = "Bill nominal annual yield", evaluate = () -> 100*terms.bill_yield, units = "%"),
        (label = "Bill equivalent continuous annual rate", evaluate = () ->
            100*equivalent_growth_rate(terms.bill_yield, bill_n), units = "%"),
        (label = "Six-month bill price", evaluate = () -> bill_price(
            terms.bill_par, terms.bill_yield, bill_n, terms.bill_maturity), units = "USD per 100 USD par"),
        (label = "Seven-year note price", evaluate = price, units = "USD per 100 USD par"),
        (label = "Macaulay duration", evaluate = macaulay, units = "years"),
        (label = "Modified duration", evaluate = modified, units = "years"),
        (label = "Convexity", evaluate = curvature, units = "years squared"),
        (label = "Estimated price change (+50 bp yield)", evaluate = () -> 100*fraction(), units = "%"),
        (label = "Exact repriced note (+50 bp yield)", evaluate = exact, units = "USD per 100 USD par"),
        (label = "Duration-convexity estimated note price", evaluate = estimate, units = "USD per 100 USD par"),
        (label = "Exact minus estimated note price", evaluate = () -> exact() - estimate(), units = "USD per 100 USD par"),
        (label = "Absolute approximation error", evaluate = () -> abs(exact() - estimate()), units = "USD per 100 USD par"),
    ];
end

"""
    advanced_report_rows() -> Vector{NamedTuple}

Display common terms, the L2a price-implied growth rate, and initial N7 holdings.
All sequences share this budget and the same time-zero market prices.
"""
function advanced_report_rows()::Vector{NamedTuple}
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    market = load_market_scenarios(joinpath(_PATH_TO_DATA, "cir-market-scenarios.csv"));
    capital = terms.liability*terms.seven_year_zero_price;
    note_price = market.prices[1,1,6]*terms.lot_par/100;
    lots = () -> affordable_lots(capital, note_price);
    return [
        (label="Common initial budget", evaluate=() -> capital, units="USD"),
        (label="Required year-7 payment", evaluate=() -> terms.liability, units="USD"),
        (label="Par amount per whole lot", evaluate=() -> terms.lot_par, units="USD par"),
        (label="Annual coupon rate for every note", evaluate=() -> 100*terms.coupon_rate, units="%"),
        (label="First one-year bill growth rate g_B", evaluate=() ->
            100*price_implied_growth_rate(market.prices[1,1,2]/100, 1.0), units="% per year"),
        (label="Initial N7 price per lot", evaluate=() -> note_price, units="USD"),
        (label="Initial N7 lots purchased", evaluate=lots, units="lots"),
        (label="Initial N7 par purchased", evaluate=() -> lots()*terms.lot_par, units="USD par"),
        (label="Initial cash after N7 purchase", evaluate=() ->
            uninvested_cash(capital, lots(), note_price), units="USD"),
        (label="N7 coupon every six months", evaluate=() ->
            coupon_payment(lots()*terms.lot_par, terms.coupon_rate, 2), units="USD"),
    ];
end

"""
    print_sequence_comparison(root::String) -> Nothing

Print all fixed strategies and save their summaries and scenario-level terminal wealth.
Results are generated from student formulas and are feedback, not official grades.
"""
function print_sequence_comparison(root::String)::Nothing
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    market = load_market_scenarios(joinpath(_PATH_TO_DATA, "cir-market-scenarios.csv"));
    rows = evaluate_sequences(market, terms);
    count = size(market.prices, 1);
    result_path = joinpath(root, "results");
    mkpath(result_path);
    summary_path = joinpath(result_path, "advanced-strategies.csv");
    outcomes_path = joinpath(result_path, "advanced-scenario-outcomes.csv");
    println("\nStrategy comparison: 50 fixed sequences plus the STRIP benchmark");
    println("B1 = one-year bill; Nm = m-year coupon note. Every sequence is chosen before the future is known.");
    @printf("%-24s %8s %14s %14s %14s\n", "Sequence", "Funded", "Mean wealth", "Mean shortfall", "Max shortfall");
    open(summary_path, "w") do summary_io
        open(outcomes_path, "w") do outcomes_io
            println(summary_io, "sequence,funded_scenarios,scenario_count,funding_fraction,mean_terminal_value,mean_shortfall,maximum_shortfall,status");
            println(outcomes_io, "sequence,scenario_id,terminal_value,funding_ratio,shortfall");
            for row ∈ rows
                if !isempty(row.detail)
                    println(row.label, ": UNAVAILABLE — ", row.detail);
                    println(summary_io, row.label, ",,$(count),,,,,unavailable");
                    continue;
                end
                result = row.summary;
                funded = Base.count(>=(terms.liability), row.terminal_values);
                @printf("%-24s %3d/%-4d %14.2f %14.2f %14.2f\n", row.label, funded, count,
                    result.mean_terminal_value, result.mean_shortfall, result.maximum_shortfall);
                @printf(summary_io, "%s,%d,%d,%.10f,%.10f,%.10f,%.10f,available\n", row.label,
                    funded, count, result.probability_funded, result.mean_terminal_value,
                    result.mean_shortfall, result.maximum_shortfall);
                for (scenario, value) ∈ enumerate(row.terminal_values)
                    @printf(outcomes_io, "%s,%d,%.10f,%.10f,%.10f\n", row.label, scenario,
                        value, row.funding_ratios[scenario], row.shortfalls[scenario]);
                end
            end
        end
    end
    println("\nFunding fractions describe these 40 simulated futures; observed maxima are not worst-case guarantees.");
    println("The same future is used for every strategy within each scenario_id.");
    println("Wrote ", summary_path);
    println("Wrote ", outcomes_path);
    return nothing;
end

"""
    print_finance_report(rows, title) -> Nothing

Display each available result; identify errors or nonfinite results as unavailable.
The report displays the student's calculations and does not award test credit.
"""
function print_finance_report(rows::AbstractVector{<:NamedTuple}, title::String)::Nothing
    println("\n", title);
    println(repeat("=", length(title)));
    println("Values come from your code. Use the public checks to verify your calculations.");
    for row ∈ rows
        try
            value = row.evaluate();
            isfinite(value) || throw(ArgumentError("calculation returned a nonfinite value"));
            @printf("%-44s %14.6f %s\n", row.label, value, row.units);
        catch caught
            println(row.label, ": UNAVAILABLE — ", sprint(showerror, caught));
        end
    end
    return nothing;
end
