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
