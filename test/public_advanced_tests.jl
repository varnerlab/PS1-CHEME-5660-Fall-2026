# Reuse exactly the same valuation checks as Standard -
include(joinpath(@__DIR__, "public_standard_tests.jl"));

"""
    advanced_public_checks() -> Vector{NamedTuple}

Check the three package valuation tasks and the supplied funding-comparison call.
The thirteen valuation checks are shared with Standard. Three independent funding
checks verify the strategy choices, capital distinction, and scenario results.
"""
function advanced_public_checks()::Vector{NamedTuple}
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "advanced-terms.csv"));
    market = load_market_scenarios(joinpath(_PATH_TO_DATA, "cir-market-scenarios.csv"));
    comparison = () -> compare_strategies(market, terms);
    return vcat(standard_public_checks(), [
        (name="Compare all four strategies and the funded STRIP", evaluate=() -> begin
            rows = comparison();
            length(rows) == 5 && Set(row.label for row in rows) ==
                Set(["STRIP7", "N7", "N2-N5", "N5-N2", "B1-B1-B1-B1-B1-B1-B1"]) &&
                all(row -> isempty(row.detail) && length(row.terminal_values) == 40, rows);
        end),
        (name="Use the available budget and identify the STRIP contribution", evaluate=() -> begin
            # A changed budget catches a hard-coded amount or an implicit STRIP-sized budget.
            altered = merge(terms, (initial_budget=73_000.0,));
            rows = compare_strategies(market, altered);
            strip = only(filter(row -> row.label == "STRIP7", rows));
            sequences = filter(row -> row.label != "STRIP7", rows);
            isapprox(strip.initial_capital, 74_967.841402; atol=1e-6) &&
                isapprox(strip.additional_contribution, 1_967.841402; atol=1e-6) &&
                length(sequences) == 4 && all(row -> row.initial_capital == 73_000.0 &&
                    row.additional_contribution == 0.0, sequences) &&
                !isapprox(only(filter(row -> row.label == "N7", rows)).summary.mean_terminal_value,
                    96_863.85173988722; atol=1e-6);
        end),
        (name="Funding results preserve timing and shortfall definitions", evaluate=() -> begin
            rows = comparison();
            expected = Dict(
                "STRIP7" => (40, 100_000.0, 0.0, 0.0),
                "N7" => (0, 96_863.85173988722, 3_136.148260112778, 4_487.960240019602),
                "N2-N5" => (7, 96_783.34392925611, 3_541.879667997212, 7_741.9099577067245),
                "N5-N2" => (2, 96_805.77743062159, 3_207.574513334727, 7_377.106876680104),
                "B1-B1-B1-B1-B1-B1-B1" => (9, 96_512.04101521143, 4_385.709719911991, 12_470.966482358184),
            );
            length(rows) == 5 && all(rows) do row
                funded, wealth, deficit, worst = expected[row.label];
                s = row.summary;
                isapprox(40*s.probability_funded, funded; atol=1e-10) &&
                    isapprox(s.mean_terminal_value, wealth; atol=1e-6) &&
                    isapprox(s.mean_shortfall, deficit; atol=1e-6) &&
                    isapprox(s.maximum_shortfall, worst; atol=1e-6) &&
                    all(isfinite, row.terminal_values) &&
                    all(isapprox.(row.funding_ratios, row.terminal_values ./ terms.liability)) &&
                    all(isapprox.(row.shortfalls, max.(terms.liability .- row.terminal_values, 0.0)));
            end;
        end),
    ]);
end
