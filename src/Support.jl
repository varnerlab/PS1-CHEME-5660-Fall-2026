"""
    load_numeric_record(path::String) -> NamedTuple

Read a two-line CSV file whose first row contains field names and whose second row
contains numeric values. This supplied helper keeps file parsing out of the student tasks.
"""
function load_numeric_record(path::String)::NamedTuple

    # Read and validate the two-row classroom data file -
    lines = [line for line ∈ readlines(path) if !isempty(strip(line))];
    length(lines) == 2 || throw(ArgumentError("expected one header row and one data row in $(path)"));

    # Convert the column labels and numeric data into a named record -
    names = Tuple(Symbol.(strip.(split(lines[1], ","))));
    values = Tuple(parse.(Float64, strip.(split(lines[2], ","))));
    length(names) == length(values) || throw(ArgumentError("header and data widths differ in $(path)"));

    return NamedTuple{names}(values);
end

"""
    note_cashflows(terms::NamedTuple) -> NamedTuple

Construct the payment times, period indices, and promised cash flows for the Standard
track note. The final cash flow includes both the last coupon and repayment of par.
"""
function note_cashflows(terms::NamedTuple)::NamedTuple

    # Build the complete semiannual schedule from the supplied contract terms -
    number_of_periods = Int(round(terms.note_compounding_frequency*terms.note_maturity));
    period_indices = collect(1:number_of_periods); # financial indices j = 1,...,N
    payment_times = period_indices ./ terms.note_compounding_frequency; # years from purchase

    # Populate the promised coupon stream and add par to the maturity payment -
    coupon_payment = (terms.note_coupon_rate/terms.note_compounding_frequency)*terms.note_par;
    cashflows = fill(coupon_payment, number_of_periods); # USD per 100 USD of par
    cashflows[end] += terms.note_par;

    return (
        payment_times = payment_times,
        period_indices = period_indices,
        cashflows = cashflows,
    );
end

"""
    load_cir_scenarios(path::String) -> NamedTuple

Read the frozen CIR-derived scenario table and return one matrix for each rate or price
quantity. Rows are scenarios and columns are one-year investment periods.
"""
function load_cir_scenarios(path::String)::NamedTuple

    # Read the supplied comma-separated scenario records -
    lines = readlines(path);
    expected_header = "scenario_id,period,short_rate,one_period_zero_price,growth_factor,bill_discount_rate";
    strip(lines[1]) == expected_header || throw(ArgumentError("unexpected CIR scenario header"));

    records = [split(strip(line), ",") for line ∈ lines[2:end] if !isempty(strip(line))];
    scenario_count = maximum(parse(Int, record[1]) for record ∈ records);
    period_count = maximum(parse(Int, record[2]) for record ∈ records);

    # Allocate one scenario-by-period matrix for each supplied financial quantity -
    short_rates = fill(NaN, scenario_count, period_count);
    zero_prices = fill(NaN, scenario_count, period_count);
    growth_factors = fill(NaN, scenario_count, period_count);
    bill_discount_rates = fill(NaN, scenario_count, period_count);

    # Place each long-form CSV record into its scenario row and period column -
    for record ∈ records
        scenario_id = parse(Int, record[1]);
        period = parse(Int, record[2]);
        short_rates[scenario_id, period] = parse(Float64, record[3]);
        zero_prices[scenario_id, period] = parse(Float64, record[4]);
        growth_factors[scenario_id, period] = parse(Float64, record[5]);
        bill_discount_rates[scenario_id, period] = parse(Float64, record[6]);
    end

    all(isfinite, short_rates) || throw(ArgumentError("the short-rate scenario matrix is incomplete"));
    all(isfinite, zero_prices) || throw(ArgumentError("the zero-price scenario matrix is incomplete"));
    all(isfinite, growth_factors) || throw(ArgumentError("the growth-factor scenario matrix is incomplete"));

    return (
        short_rates = short_rates,
        zero_prices = zero_prices,
        growth_factors = growth_factors,
        bill_discount_rates = bill_discount_rates,
    );
end

"""
    scenario_terminal_values(initial_value::Real, growth_factor_matrix::AbstractMatrix) -> Vector{Float64}

Apply the student's one-scenario `terminal_wealth` calculation to every supplied scenario.
The iteration is provided because scenario bookkeeping is not a learning objective of PS1.
"""
function scenario_terminal_values(initial_value::Real,
    growth_factor_matrix::AbstractMatrix)::Vector{Float64}

    # Evaluate one complete roll path in each scenario row -
    number_of_scenarios = size(growth_factor_matrix, 1);
    terminal_values = Array{Float64,1}(undef, number_of_scenarios);
    for scenario_id ∈ 1:number_of_scenarios
        factors = view(growth_factor_matrix, scenario_id, :); # one factor for each roll period
        terminal_values[scenario_id] = terminal_wealth(initial_value, factors);
    end

    return terminal_values;
end
