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

Build the lock-versus-roll calculations using the student's Advanced functions.
Probabilities and extrema describe only the supplied, equally weighted scenarios.
"""
function advanced_report_rows()::Vector{NamedTuple}
    # Load the liability and frozen scenario paths -
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    scenarios = load_cir_scenarios(joinpath(_PATH_TO_DATA, "cir-rate-scenarios.csv"));
    first_price = scenarios.zero_prices[1,1];
    initial = () -> lock_cost(terms.liability, terms.seven_period_zero_price);
    terminal = () -> scenario_terminal_values(initial(), scenarios.growth_factors);

    return [
        (label = "First CIR short rate", evaluate = () -> 100*scenarios.short_rates[1,1], units = "% per year"),
        (label = "First price-implied continuous zero yield", evaluate = () ->
            100*price_implied_growth_rate(first_price, 1.0), units = "% per year"),
        (label = "First one-period growth factor", evaluate = () -> growth_factor(first_price), units = "USD per USD invested"),
        (label = "Initial capital / lock cost", evaluate = initial, units = "USD"),
        (label = "Lock terminal payment", evaluate = () -> terms.liability, units = "USD (under model assumptions)"),
        (label = "Supplied scenario count", evaluate = () -> size(scenarios.growth_factors, 1), units = "scenarios"),
        (label = "Roll fully funded scenarios", evaluate = () -> count(>=(terms.liability), terminal()), units = "scenarios"),
        (label = "Roll fully funded fraction", evaluate = () ->
            100*funding_probability(terminal(), terms.liability), units = "% of supplied scenarios"),
        (label = "Roll mean terminal value", evaluate = () -> mean(terminal()), units = "USD"),
        (label = "Roll mean shortfall (all scenarios)", evaluate = () -> mean_shortfall(terminal(), terms.liability), units = "USD"),
        (label = "Roll maximum observed shortfall", evaluate = () -> maximum_shortfall(terminal(), terms.liability), units = "USD"),
        (label = "Roll first-scenario funding ratio", evaluate = () -> funding_ratio(terminal()[1], terms.liability), units = "USD per USD owed"),
        (label = "Roll maximum observed terminal value", evaluate = () -> maximum(terminal()), units = "USD"),
    ];
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
