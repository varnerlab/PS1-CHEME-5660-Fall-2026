# PS1 Standard Track
#
# Complete only the expressions marked TODO. The supplied code handles file input,
# cash-flow construction, and testing so the work remains focused on finance.

"""
    equivalent_growth_rate(y::Real, n::Integer) -> Float64

Return the continuously compounded annual growth rate equivalent to nominal annual
yield `y` compounded `n` times per year:

    g_y = n*log(1 + y/n)
"""
function equivalent_growth_rate(y::Real, n::Integer)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("equivalent_growth_rate is not implemented yet");
end

"""
    bill_price(par::Real, y::Real, n::Integer, T::Real) -> Float64

Return the zero-NPV purchase price of a bill under nominal annual yield `y` compounded
`n` times per year over `T` years:

    V_B = V_P*(1 + y/n)^(-n*T)
"""
function bill_price(par::Real, y::Real, n::Integer, T::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("bill_price is not implemented yet");
end

"""
    price_implied_growth_rate(price::Real, par::Real, T::Real) -> Float64

Return the annualized continuously compounded growth rate implied by a zero-coupon
purchase price and maturity payment:

    g_B = log(V_P/V_B)/T
"""
function price_implied_growth_rate(price::Real, par::Real, T::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("price_implied_growth_rate is not implemented yet");
end

"""
    discount_factors(y::Real, n::Integer, payment_times::AbstractVector) -> Vector{Float64}

Return one discount factor for every payment time `t_j`, measured in years:

    D(0,t_j) = (1 + y/n)^(-n*t_j)
"""
function discount_factors(y::Real, n::Integer,
    payment_times::AbstractVector)::Vector{Float64}
    # TODO: Use broadcasting (the dot operators) to evaluate the equation at every time.
    throw("discount_factors is not implemented yet");
end

"""
    present_value(cashflows::AbstractVector, discounts::AbstractVector) -> Float64

Return the sum of the discounted cash flows:

    V_B = sum(CF_j*D(0,t_j))
"""
function present_value(cashflows::AbstractVector, discounts::AbstractVector)::Float64
    # TODO: Multiply aligned cash flows and discount factors, then add the products.
    throw("present_value is not implemented yet");
end

"""
    macaulay_duration(payment_times, cashflows, discounts, price) -> Float64

Return the present-value-weighted average payment time:

    D_mac = sum(t_j*CF_j*D(0,t_j))/V_B
"""
function macaulay_duration(payment_times::AbstractVector, cashflows::AbstractVector,
    discounts::AbstractVector, price::Real)::Float64
    # TODO: Translate the displayed weighted-average equation into one expression.
    throw("macaulay_duration is not implemented yet");
end

"""
    modified_duration(macaulay::Real, y::Real, n::Integer) -> Float64

Convert Macaulay duration to modified duration:

    D_mod = D_mac/(1 + y/n)
"""
function modified_duration(macaulay::Real, y::Real, n::Integer)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("modified_duration is not implemented yet");
end

"""
    convexity(period_indices, cashflows, discounts, price, y, n) -> Float64

Return the convexity of a discretely compounded fixed cash-flow stream:

    K = sum(j*(j+1)*CF_j*D_j)/(n^2*V_B*(1 + y/n)^2)
"""
function convexity(period_indices::AbstractVector, cashflows::AbstractVector,
    discounts::AbstractVector, price::Real, y::Real, n::Integer)::Float64
    # TODO: Translate the displayed equation into one expression.
    throw("convexity is not implemented yet");
end

"""
    price_change_fraction(modified::Real, convexity_value::Real, yield_change::Real) -> Float64

Estimate the fractional price change using duration and convexity:

    Delta V/V approximately -D_mod*Delta y + (1/2)*K*(Delta y)^2
"""
function price_change_fraction(modified::Real, convexity_value::Real,
    yield_change::Real)::Float64
    # TODO: Translate the displayed approximation into one Julia expression.
    throw("price_change_fraction is not implemented yet");
end

