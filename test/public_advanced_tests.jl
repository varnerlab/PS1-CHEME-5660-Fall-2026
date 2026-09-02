"""
    advanced_public_checks() -> Vector{NamedTuple}

Return the individual public checks for the Advanced track. Each check is evaluated
independently so the rubric can count successful tests even when another function errors.
"""
function advanced_public_checks()::Vector{NamedTuple}

    # Load the fixed liability terms and frozen CIR-derived scenario table -
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    scenarios = load_cir_scenarios(joinpath(_PATH_TO_DATA, "cir-rate-scenarios.csv"));

    # Define reusable calculations; each public check invokes only the work it needs -
    first_price = scenarios.zero_prices[1,1];
    initial_value = () -> lock_cost(terms.liability, terms.seven_period_zero_price);
    terminal_values = () -> scenario_terminal_values(
        initial_value(), scenarios.growth_factors);
    summary = () -> funding_summary(terminal_values(), terms.liability);

    return [
        (name = "One-period zero price implies its model yield",
            evaluate = () -> isapprox(
                price_implied_growth_rate(first_price, 1.0),
                0.04399209136764926; atol = 1e-12)),
        (name = "One-period zero price implies its growth factor",
            evaluate = () -> isapprox(
                growth_factor(first_price), 1.044974090539866; atol = 1e-12)),
        (name = "The CIR short rate is not the one-period zero yield",
            evaluate = () -> !isapprox(
                price_implied_growth_rate(first_price, 1.0),
                scenarios.short_rates[1,1]; atol = 1e-6)),
        (name = "Computed growth factor agrees with the frozen data",
            evaluate = () -> isapprox(
                growth_factor(first_price), scenarios.growth_factors[1,1]; atol = 1e-10)),
        (name = "Exact-maturity liability lock cost",
            evaluate = () -> isapprox(initial_value(), 74_967.8414; atol = 1e-6)),
        (name = "Terminal wealth compounds every roll factor",
            evaluate = () -> isapprox(
                terminal_wealth(10_000.0, [1.02, 1.03, 1.01]),
                10_000.0*1.02*1.03*1.01; atol = 1e-10)),
        (name = "One terminal value is returned for every scenario",
            evaluate = () -> length(terminal_values()) == 40),
        (name = "First scenario terminal value",
            evaluate = () -> isapprox(
                terminal_values()[1], 108_397.6179071269; atol = 1e-6)),
        (name = "Worst terminal value across the frozen scenarios",
            evaluate = () -> isapprox(
                minimum(terminal_values()), 89_879.51251480076; atol = 1e-6)),
        (name = "Funding ratio",
            evaluate = () -> isapprox(
                funding_ratio(108_000.0, terms.liability), 1.08; atol = 1e-12)),
        (name = "Positive funding shortfall",
            evaluate = () -> isapprox(
                shortfall(97_500.0, terms.liability), 2_500.0; atol = 1e-12)),
        (name = "Funded scenario has zero shortfall",
            evaluate = () -> iszero(shortfall(101_000.0, terms.liability))),
        (name = "Probability of fully funding the liability",
            evaluate = () -> isapprox(summary().probability_funded, 0.40; atol = 1e-12)),
        (name = "Mean terminal value",
            evaluate = () -> isapprox(
                summary().mean_terminal_value, 99_455.9093414888; atol = 1e-6)),
        (name = "Mean funding shortfall",
            evaluate = () -> isapprox(
                summary().mean_shortfall, 2_434.0430404689546; atol = 1e-6)),
        (name = "Maximum funding shortfall",
            evaluate = () -> isapprox(
                summary().maximum_shortfall, 10_120.487485199235; atol = 1e-6)),
    ];
end

