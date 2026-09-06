using Printf # labeled numerical output with enough precision to compare repricing errors

"""
    standard_report_rows() -> Vector{NamedTuple}

Connect the student's package-model tasks to the supplied financial report.
Each row is evaluated independently, so unfinished bill work does not suppress
available note results. Prices are reported in USD per USD 100 par.
"""
function standard_report_rows()::Vector{NamedTuple}
    # Load terms and defer each student task until its result is requested -
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "standard-terms.csv"));
    bill = () -> build_bill(terms);
    note = () -> build_note(terms);
    rates = () -> standard_bill_rates(bill());
    risk = () -> standard_note_risk(note());
    fraction = () -> standard_price_change(note(), terms.yield_change);
    exact = () -> reprice_note(note(), terms.yield_change).price;
    estimate = () -> note().price*(1 + fraction());

    return [
        (label = "Bill nominal annual yield y", evaluate = () -> 100*terms.bill_yield, units = "%"),
        (label = "Bill equivalent continuous rate g_y", evaluate = () -> 100*rates().equivalent, units = "%"),
        (label = "Bill price-implied continuous rate g_B", evaluate = () -> 100*rates().implied, units = "%"),
        (label = "Six-month bill price", evaluate = () -> bill().price, units = "USD per 100 USD par"),
        (label = "Seven-year note price", evaluate = () -> note().price, units = "USD per 100 USD par"),
        (label = "Macaulay duration D_mac", evaluate = () -> risk().macaulay, units = "years"),
        (label = "Modified duration D_mod", evaluate = () -> risk().modified, units = "years"),
        (label = "Convexity K", evaluate = () -> risk().convexity, units = "years squared"),
        (label = "Estimated price change ΔV_B/V_B (+50 bp)", evaluate = () -> 100*fraction(), units = "%"),
        (label = "Exact repriced note (+50 bp yield)", evaluate = exact, units = "USD per 100 USD par"),
        (label = "Duration-convexity estimated note price", evaluate = estimate, units = "USD per 100 USD par"),
        (label = "Exact minus estimated note price", evaluate = () -> exact() - estimate(), units = "USD per 100 USD par"),
        (label = "Absolute approximation error", evaluate = () -> abs(exact() - estimate()), units = "USD per 100 USD par"),
    ];
end

"""
    advanced_report_rows() -> Vector{NamedTuple}

Display the shared valuation results and the funding decision's initial amounts.
The supplied STRIP quote determines its capital requirement. The valuation exercise's
single nominal yield is separate from the simulated funding market's price curves.
"""
function advanced_report_rows()::Vector{NamedTuple}
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    plan = strip_funding(terms);
    return vcat(standard_report_rows(), [
        (label="Available initial budget", evaluate=() -> terms.initial_budget, units="USD"),
        (label="Required year-7 payment", evaluate=() -> terms.liability, units="USD"),
        (label="Fully funded STRIP initial cost", evaluate=() -> plan.initial_capital, units="USD"),
        (label="Additional contribution for STRIP today", evaluate=() -> plan.additional_contribution, units="USD"),
        (label="Fully funded STRIP lots", evaluate=() -> plan.lots, units="lots"),
    ]);
end

"""
    print_sequence_comparison(root::String) -> Nothing

Call the student's comparison task and display each strategy's capital and funding
results. Save summaries and individual futures under results/. The additional capital
column identifies the funded STRIP's contribution, preventing comparison as equal budgets.
An unfinished comparison propagates to the checker's financial-report error handler.
"""
function print_sequence_comparison(root::String)::Nothing
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    market = load_market_scenarios(joinpath(_PATH_TO_DATA, "cir-market-scenarios.csv"));
    rows = compare_strategies(market, terms);
    scenario_count = size(market.prices, 1);
    result_path = joinpath(root, "results");
    mkpath(result_path);
    summary_path = joinpath(result_path, "advanced-strategies.csv");
    outcomes_path = joinpath(result_path, "advanced-scenario-outcomes.csv");
    println("\nFunding comparison: four strategies at the available budget and STRIP with extra capital");
    println("B1 = one-year bill; Nm = m-year coupon note. All monetary results are USD.");
    @printf("%-24s %12s %12s %8s %14s %14s %14s\n", "Strategy", "Capital", "Extra today", "Funded", "Mean wealth", "Mean shortfall", "Max shortfall");
    open(summary_path, "w") do summary_io
        open(outcomes_path, "w") do outcomes_io
            println(summary_io, "sequence,initial_capital,additional_contribution,funded_scenarios,scenario_count,funding_fraction,mean_terminal_value,mean_shortfall,maximum_shortfall,status");
            println(outcomes_io, "sequence,initial_capital,additional_contribution,scenario_id,terminal_value,funding_ratio,shortfall");
            for row in rows
                if !isempty(row.detail)
                    println(row.label, ": UNAVAILABLE — ", row.detail);
                    println(summary_io, join((row.label,row.initial_capital,row.additional_contribution,"",scenario_count,"","","","","unavailable"), ','));
                    continue;
                end
                result = row.summary;
                funded = count(>=(terms.liability), row.terminal_values);
                @printf("%-24s %12.2f %12.2f %3d/%-4d %14.2f %14.2f %14.2f\n", row.label,
                    row.initial_capital, row.additional_contribution, funded, scenario_count,
                    result.mean_terminal_value, result.mean_shortfall, result.maximum_shortfall);
                @printf(summary_io, "%s,%.10f,%.10f,%d,%d,%.10f,%.10f,%.10f,%.10f,available\n", row.label,
                    row.initial_capital, row.additional_contribution, funded, scenario_count,
                    result.probability_funded, result.mean_terminal_value, result.mean_shortfall, result.maximum_shortfall);
                for (scenario, value) in enumerate(row.terminal_values)
                    @printf(outcomes_io, "%s,%.10f,%.10f,%d,%.10f,%.10f,%.10f\n", row.label,
                        row.initial_capital, row.additional_contribution, scenario, value,
                        row.funding_ratios[scenario], row.shortfalls[scenario]);
                end
            end
        end
    end
    println("\nSTRIP7 receives additional capital today. The four sequences receive only the available budget.");
    println("Funding fractions describe the supplied futures; observed maxima are not worst-case guarantees.");
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
    println("Results use your completed tasks and the supplied reporting functions.");
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
