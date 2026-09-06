"""
    standard_public_checks() -> Vector{NamedTuple}

Return thirteen checks of the student's bill, note, and repricing tasks.
Repricing checks use a supplied package model so unfinished construction tasks
retain independent credit. Each result has a name and a deferred Boolean check.
"""
function standard_public_checks()::Vector{NamedTuple}
    terms = load_numeric_record(joinpath(_PATH_TO_DATA, "standard-terms.csv"));
    bill = () -> build_bill(terms);
    note = () -> build_note(terms);

    # Supply a fresh priced note for each independent repricing check -
    reference_note = () -> build(MyUSTreasuryCouponSecurityModel, (
        par=terms.note_par, rate=terms.note_yield, coupon=terms.note_coupon_rate,
        T=terms.note_maturity, λ=Int(terms.note_compounding_frequency),
    )) |> DiscreteCompoundingModel();
    repriced = () -> reprice_note(reference_note(), terms.yield_change);

    # Check the entire student workflow once all three tasks can run -
    full_workflow = () -> begin
        b = bill();
        original = note();
        changed = reprice_note(original, terms.yield_change);
        estimate = original.price*(1 + standard_price_change(original, terms.yield_change));
        isapprox(b.price, 97.56097560975611; atol=1e-10) &&
            isapprox(original.price, 97.92545962882491; atol=1e-10) &&
            isapprox(changed.price, 95.04852622680231; atol=1e-9) &&
            abs(estimate - changed.price) < 0.01;
    end;

    return [
        (name="Bill uses the supplied terms", evaluate=() -> begin
            b=bill();
            b.par == terms.bill_par && b.rate == terms.bill_yield &&
                b.T == terms.bill_maturity && b.n == terms.bill_compounding_frequency;
        end),
        (name="Six-month bill price", evaluate=() ->
            isapprox(bill().price, 97.56097560975611; atol=1e-10)),
        (name="Bill has the expected purchase and maturity cash flows", evaluate=() -> begin
            b=bill();
            isapprox(b.cashflow[0], -97.56097560975611; atol=1e-10) &&
                b.cashflow[1] == terms.bill_par;
        end),
        (name="Note uses the supplied terms", evaluate=() -> begin
            model=note();
            model.par == terms.note_par && model.rate == terms.note_yield &&
                model.coupon == terms.note_coupon_rate && model.T == terms.note_maturity &&
                model.λ == terms.note_compounding_frequency;
        end),
        (name="Seven-year coupon note price", evaluate=() ->
            isapprox(note().price, 97.92545962882491; atol=1e-10)),
        (name="Note contains the purchase and fourteen future payment dates", evaluate=() ->
            sort(collect(keys(note().cashflow))) == collect(0:14)),
        (name="Note cash flows include the final coupon and principal", evaluate=() -> begin
            model=note();
            isapprox(model.cashflow[1], 2.125/1.023; atol=1e-10) &&
                isapprox(model.cashflow[14], 102.125/1.023^14; atol=1e-10);
        end),
        (name="Priced note gives the expected supplied risk report", evaluate=() -> begin
            risk=standard_note_risk(note());
            isapprox(risk.macaulay, 6.116505651686405; atol=1e-10) &&
                isapprox(risk.modified, 5.978988906829331; atol=1e-10) &&
                isapprox(risk.convexity, 41.817667688340755; atol=1e-9);
        end),
        (name="Repricing adds 50 basis points and preserves the contract", evaluate=() -> begin
            model=repriced();
            isapprox(model.rate, 0.051; atol=1e-12) && model.coupon == terms.note_coupon_rate &&
                model.par == terms.note_par && model.T == terms.note_maturity &&
                model.λ == terms.note_compounding_frequency;
        end),
        (name="Repriced note has the expected lower price", evaluate=() ->
            isapprox(repriced().price, 95.04852622680231; atol=1e-9)),
        (name="Repricing leaves the original model unchanged", evaluate=() -> begin
            original=reference_note();
            original_cashflow=copy(original.cashflow);
            original_discount=copy(original.discount);
            changed=reprice_note(original, terms.yield_change);
            changed !== original && original.rate == terms.note_yield &&
                isapprox(original.price, 97.92545962882491; atol=1e-10) &&
                original.cashflow == original_cashflow && original.discount == original_discount;
        end),
        (name="Repriced cash flows agree with the updated price", evaluate=() -> begin
            model=repriced();
            isapprox(model.cashflow[14], 102.125/1.0255^14; atol=1e-10) &&
                isapprox(sum(model.cashflow[j] for j ∈ 1:14), model.price; atol=1e-10) &&
                isapprox(model.cashflow[0], -model.price; atol=1e-10);
        end),
        (name="Complete workflow agrees with the supplied repricing estimate", evaluate=full_workflow),
    ];
end
