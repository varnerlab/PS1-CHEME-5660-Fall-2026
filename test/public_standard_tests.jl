"""
    standard_public_checks() -> Vector{NamedTuple}

Return the individual public checks for the Standard track. Each check is evaluated
independently so the rubric can count successful tests even when another function errors.
"""
function standard_public_checks()::Vector{NamedTuple}

    # Load the controlled security terms and supplied note schedule -
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "standard-terms.csv"));
    schedule = note_cashflows(terms);
    bill_n = Int(terms.bill_compounding_frequency);
    note_n = Int(terms.note_compounding_frequency);

    # Define reusable calculations; each public check invokes only the work it needs -
    bill_growth = () -> equivalent_growth_rate(terms.bill_yield, bill_n);
    bill_value = () -> bill_price(
        terms.bill_par, terms.bill_yield, bill_n, terms.bill_maturity);
    note_discounts = () -> discount_factors(
        terms.note_yield, note_n, schedule.payment_times);
    note_value = () -> present_value(schedule.cashflows, note_discounts());
    macaulay = () -> macaulay_duration(
        schedule.payment_times, schedule.cashflows, note_discounts(), note_value());
    modified = () -> modified_duration(macaulay(), terms.note_yield, note_n);
    convexity_value = () -> convexity(
        schedule.period_indices, schedule.cashflows, note_discounts(),
        note_value(), terms.note_yield, note_n);
    estimated_fraction = () -> price_change_fraction(
        modified(), convexity_value(), terms.yield_change);
    exact_shocked_value = () -> present_value(
        schedule.cashflows,
        discount_factors(
            terms.note_yield + terms.yield_change, note_n, schedule.payment_times),
    );

    return [
        (name = "Equivalent continuously compounded growth rate",
            evaluate = () -> isapprox(bill_growth(), 0.04938522518074283; atol = 1e-12)),
        (name = "Six-month Treasury bill price",
            evaluate = () -> isapprox(bill_value(), 97.56097560975611; atol = 1e-10)),
        (name = "Bill price implies the equivalent growth rate",
            evaluate = () -> isapprox(
                price_implied_growth_rate(
                    bill_value(), terms.bill_par, terms.bill_maturity),
                bill_growth(); atol = 1e-12)),
        (name = "Seven-year note has fourteen discount factors",
            evaluate = () -> length(note_discounts()) == 14),
        (name = "First note discount factor",
            evaluate = () -> isapprox(note_discounts()[1], 0.9775171065493646; atol = 1e-12)),
        (name = "Maturity-date note discount factor",
            evaluate = () -> isapprox(note_discounts()[end], 0.7273461226455469; atol = 1e-12)),
        (name = "Seven-year coupon note price",
            evaluate = () -> isapprox(note_value(), 97.92545962882491; atol = 1e-10)),
        (name = "Macaulay duration",
            evaluate = () -> isapprox(macaulay(), 6.116505651686405; atol = 1e-10)),
        (name = "Modified duration",
            evaluate = () -> isapprox(modified(), 5.978988906829331; atol = 1e-10)),
        (name = "Convexity",
            evaluate = () -> isapprox(convexity_value(), 41.817667688340755; atol = 1e-9)),
        (name = "Duration-convexity price-change estimate",
            evaluate = () -> isapprox(
                estimated_fraction(), -0.029372223688042393; atol = 1e-12)),
        (name = "A higher yield lowers the estimated note price",
            evaluate = () -> estimated_fraction() < 0),
        (name = "Approximation is within one cent of exact repricing",
            evaluate = () -> abs(
                note_value()*(1 + estimated_fraction()) - exact_shocked_value()) < 0.01),
    ];
end

