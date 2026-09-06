"""
    advanced_public_checks() -> Vector{NamedTuple}

Check individual financial formulas with supplied inputs, then exercise cash-flow
accounting and the full strategy comparison. Evaluate each check independently.
"""
function advanced_public_checks()::Vector{NamedTuple}
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    market = load_market_scenarios(joinpath(_PATH_TO_DATA, "cir-market-scenarios.csv"));
    sample_values = [90_000.0, 100_000.0, 110_000.0]; # includes exact funding
    sample_terms = (liability=25_000.0, lot_par=10_000.0, coupon_rate=0.04,
        compounding_frequency=2.0, horizon_years=2.0, seven_year_zero_price=1.0);
    sample_market = (prices=fill(100.0, 1, 14, 6), short_rates=zeros(1,14));
    return [
        (name="Price-implied annualized growth rate g_B",
            evaluate=() -> isapprox(price_implied_growth_rate(market.prices[1,1,2]/100, 1.0),
                0.04399209136764926; atol=1e-10)),
        (name="Growth rate uses the stated holding time",
            evaluate=() -> isapprox(price_implied_growth_rate(0.90, 2.0),
                0.05268025782891314; atol=1e-12)),
        (name="Buy only affordable whole lots",
            evaluate=() -> affordable_lots(25_000.0, 9_800.0) == 2),
        (name="An exactly affordable lot can be purchased",
            evaluate=() -> affordable_lots(9_800.0, 9_800.0) == 1),
        (name="Insufficient cash buys zero lots",
            evaluate=() -> affordable_lots(9_799.0, 9_800.0) == 0),
        (name="Carry residual cash after purchase",
            evaluate=() -> isapprox(uninvested_cash(25_000.0, 2, 9_800.0), 5_400.0; atol=1e-10)),
        (name="A fully invested cash balance leaves zero residual",
            evaluate=() -> iszero(uninvested_cash(19_600.0, 2, 9_800.0))),
        (name="Semiannual coupon on held par",
            evaluate=() -> isapprox(coupon_payment(70_000.0, 0.0425, 2), 1_487.5; atol=1e-10)),
        (name="Funding ratio",
            evaluate=() -> isapprox(funding_ratio(108_000.0, 100_000.0), 1.08; atol=1e-12)),
        (name="Positive funding shortfall",
            evaluate=() -> isapprox(shortfall(97_500.0, 100_000.0), 2_500.0; atol=1e-10)),
        (name="Funded scenario has zero shortfall",
            evaluate=() -> iszero(shortfall(101_000.0, 100_000.0))),
        (name="Funding fraction counts equality as funded",
            evaluate=() -> isapprox(funding_probability(sample_values, 100_000.0), 2/3; atol=1e-12)),
        (name="Mean shortfall includes funded scenarios as zero",
            evaluate=() -> isapprox(mean_shortfall(sample_values, 100_000.0), 10_000/3; atol=1e-8)),
        (name="Maximum observed shortfall",
            evaluate=() -> isapprox(maximum_shortfall(sample_values, 100_000.0), 10_000.0; atol=1e-8)),
        (name="Coupon note plus residual cash: complete dated calculation",
            evaluate=() -> isapprox(simulate_sequence([2], sample_market, 1, sample_terms).terminal_value,
                26_600.0; atol=1e-8)),
        (name="All 50 sequences and the STRIP across the common scenarios",
            evaluate=() -> begin
                rows = evaluate_sequences(market, terms);
                length(rows) == 51 && all(row -> isempty(row.detail), rows) &&
                    all(row -> length(row.terminal_values) == 40, rows) &&
                    rows[1].summary.probability_funded == 1.0 &&
                    all(row -> all(isfinite, row.terminal_values), rows) &&
                    isapprox(only(filter(row -> row.label == "N7", rows)).summary.mean_terminal_value,
                        98_158.57058734333; atol=1e-6) &&
                    isapprox(only(filter(row -> row.label == "B1-B1-B1-B1-B1-B1-B1", rows)).summary.mean_shortfall,
                        3_404.9151915119; atol=1e-6);
            end),
    ];
end
