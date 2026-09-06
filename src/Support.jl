"""
    load_numeric_record(path::String) -> NamedTuple

Read a CSV file with one header and one numeric row, ignoring blank lines.
Return a NamedTuple whose field names come from the header and whose values are
Float64 numbers. `path` names a supplied terms file.

Throw ArgumentError for an incorrect row count, unequal row widths, or an invalid
number. File-access errors propagate to the checker.
"""
function load_numeric_record(path::String)::NamedTuple

    # Read and validate the two-row terms file -
    lines = [line for line ∈ readlines(path) if !isempty(strip(line))];
    length(lines) == 2 || throw(ArgumentError("expected one header row and one data row in $(path)"));

    # Convert the column labels and numeric data into a named record -
    names = Tuple(Symbol.(strip.(split(lines[1], ","))));
    values = Tuple(parse.(Float64, strip.(split(lines[2], ","))));
    length(names) == length(values) || throw(ArgumentError("header and data widths differ in $(path)"));

    return NamedTuple{names}(values);
end

"""
    standard_bill_rates(bill::MyUSTreasuryZeroCouponBondModel) -> NamedTuple

Report the equivalent continuous rate `g_y` from L1b, "Continuous Compounding",
and the price-implied rate `g_B` from L2a, "Valuing a T-Bill". Return decimal
annual rates in fields `equivalent` and `implied`, using the priced bill's inputs.
Assume a positive price, par and maturity, and `1 + rate/n > 0`.
"""
function standard_bill_rates(bill::MyUSTreasuryZeroCouponBondModel)::NamedTuple
    # Convert the nominal yield and the actual purchase price separately -
    equivalent = bill.n*log(1 + bill.rate/bill.n); # g_y, per year
    implied = log(bill.par/bill.price)/bill.T; # g_B, per year
    return (equivalent=equivalent, implied=implied);
end

"""
    standard_note_risk(note::MyUSTreasuryCouponSecurityModel) -> NamedTuple

Compute the supplied duration and convexity report from a priced package model.
L2b gives the equations in "Price-Yield Geometry" and "Duration and Convexity as
Risk Measures". Return `macaulay` and `modified` in years, and `convexity` in years
squared. The model uses a positive semiannual schedule and a decimal annual yield.

In this package, `note.cashflow[j]` already contains each payment's present value.
Its period-0 entry is the negative purchase price. Use only periods 1 through N,
without discounting those entries again. `note.discount[j]` stores forward
accumulation factors, despite the field's name.
"""
function standard_note_risk(note::MyUSTreasuryCouponSecurityModel)::NamedTuple
    # Read the discounted future receipts produced by the course package -
    n = note.λ; # payments per year
    periods = sort([j for j ∈ keys(note.cashflow) if j > 0]); # omit the purchase at j = 0
    present_values = [note.cashflow[j] for j ∈ periods]; # already discounted, USD
    payment_times = periods ./ n; # t_j = j/n, in years

    # Apply L2b's timing and yield-sensitivity equations to the package results -
    macaulay = sum(payment_times .* present_values)/note.price;
    modified = macaulay/(1 + note.rate/n);
    curvature = sum(periods .* (periods .+ 1) .* present_values)/
        (n^2*note.price*(1 + note.rate/n)^2); # normalized second yield derivative
    return (macaulay=macaulay, modified=modified, convexity=curvature);
end

"""
    standard_price_change(note::MyUSTreasuryCouponSecurityModel, yield_change::Real)
        -> Float64

Return L2b's duration-convexity estimate of the fractional change in note price.
`yield_change` is an additive decimal annual yield change, so 50 basis points is
0.005. The returned fraction must be multiplied by 100 for a percentage display.
The cash flows and remaining maturity are held fixed.
"""
function standard_price_change(note::MyUSTreasuryCouponSecurityModel,
    yield_change::Real)::Float64
    # Combine the slope and curvature terms from L2b, "Estimating a Price Change" -
    risk = standard_note_risk(note);
    return -risk.modified*yield_change + 0.5*risk.convexity*yield_change^2;
end
