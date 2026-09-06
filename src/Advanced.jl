# PS1 Advanced Track
#
# Complete only the expressions marked TODO. CIR simulation, file input, and scenario
# iteration are supplied so the work remains focused on funding the future obligation.

"""
    price_implied_growth_rate(zero_price::Real, T::Real) -> Float64

Return the price-implied annualized log growth rate `g_B` from L2a, given a price
per dollar of maturity value and a remaining holding time `T` in years:

    g_B = log(1/P)/T = -log(P)/T

This equals L1b's benchmark `g_y = 2*log(1 + y/2)` only when `P` is the
zero-NPV model price at the chosen valuation yield `y` under `n = 2`.
"""
function price_implied_growth_rate(zero_price::Real, T::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("price_implied_growth_rate is not implemented yet");
end

"""
    affordable_lots(cash::Real, price_per_lot::Real) -> Int

Return the number of whole lots affordable without borrowing. Inputs are available
cash and the purchase price of one 10,000 USD-par lot, both in USD:

    lots = floor(cash/price_per_lot)

Assume cash >= 0 and price_per_lot > 0. Use `floor(Int, ...)` to return an integer.
"""
function affordable_lots(cash::Real, price_per_lot::Real)::Int
    # TODO: Round the affordable number of lots down to an integer.
    throw("affordable_lots is not implemented yet");
end

"""
    uninvested_cash(cash::Real, lots::Integer, price_per_lot::Real) -> Float64

Return the cash remaining after purchasing `lots` whole lots, in USD:

    remainder = cash - lots*price_per_lot

The supplied engine passes a nonnegative, affordable lot count. Residual cash earns zero.
"""
function uninvested_cash(cash::Real, lots::Integer, price_per_lot::Real)::Float64
    # TODO: Subtract the total purchase cost from the available cash.
    throw("uninvested_cash is not implemented yet");
end

"""
    coupon_payment(par::Real, coupon_rate::Real, n::Integer) -> Float64

Return one coupon payment in USD on the total held par amount, following L2a:

    C = par*coupon_rate/n

Here coupon_rate is a decimal annual coupon rate and n = 2 payments per year.
"""
function coupon_payment(par::Real, coupon_rate::Real, n::Integer)::Float64
    # TODO: Translate the displayed coupon equation into one expression.
    throw("coupon_payment is not implemented yet");
end

"""
    funding_ratio(terminal_value::Real, liability::Real) -> Float64

Return terminal wealth per dollar of required outlay:

    funding ratio = W_7/L
"""
function funding_ratio(terminal_value::Real, liability::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("funding_ratio is not implemented yet");
end

"""
    shortfall(terminal_value::Real, liability::Real) -> Float64

Return the unfunded amount, with a floor of zero:

    shortfall = max(L - W_7, 0)
"""
function shortfall(terminal_value::Real, liability::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("shortfall is not implemented yet");
end

"""
    funding_probability(terminal_values::AbstractVector, liability::Real) -> Float64

Return the fraction of scenarios in which terminal wealth meets or exceeds the liability.
"""
function funding_probability(terminal_values::AbstractVector,
    liability::Real)::Float64
    # TODO: Count funded scenarios and divide by the total number of scenarios.
    throw("funding_probability is not implemented yet");
end

"""
    mean_shortfall(terminal_values::AbstractVector, liability::Real) -> Float64

Return the average shortfall across all scenarios, treating funded scenarios as zero.
"""
function mean_shortfall(terminal_values::AbstractVector,
    liability::Real)::Float64
    # TODO: Apply `shortfall` to every terminal value and take the mean.
    throw("mean_shortfall is not implemented yet");
end

"""
    maximum_shortfall(terminal_values::AbstractVector, liability::Real) -> Float64

Return the largest shortfall observed across the supplied scenarios.
"""
function maximum_shortfall(terminal_values::AbstractVector,
    liability::Real)::Float64
    # TODO: Apply `shortfall` to every terminal value and take the maximum.
    throw("maximum_shortfall is not implemented yet");
end

"""
    funding_summary(terminal_values::AbstractVector, liability::Real) -> NamedTuple

Assemble the required funding-risk statistics. This orchestration code is supplied;
students implement the finance calculations called here.
"""
function funding_summary(terminal_values::AbstractVector,
    liability::Real)::NamedTuple

    return (
        probability_funded = funding_probability(terminal_values, liability),
        mean_terminal_value = mean(terminal_values),
        mean_shortfall = mean_shortfall(terminal_values, liability),
        maximum_shortfall = maximum_shortfall(terminal_values, liability),
    );
end

