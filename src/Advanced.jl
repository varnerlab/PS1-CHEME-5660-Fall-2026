# PS1 Advanced Track
#
# Complete only the expressions marked TODO. CIR simulation, file input, and scenario
# iteration are supplied so the work remains focused on the lock-versus-roll decision.

"""
    price_implied_growth_rate(zero_price::Real, T::Real) -> Float64

Return the annualized continuously compounded zero yield implied by a price per dollar
of maturity value:

    z(t,T) = -log(P(t,T))/T
"""
function price_implied_growth_rate(zero_price::Real, T::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("price_implied_growth_rate is not implemented yet");
end

"""
    growth_factor(zero_price::Real) -> Float64

Return the maturity wealth received per dollar invested in a zero-coupon position:

    G = 1/P
"""
function growth_factor(zero_price::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("growth_factor is not implemented yet");
end

"""
    lock_cost(liability::Real, seven_period_zero_price::Real) -> Float64

Return the amount invested today in a seven-period principal STRIP to fund the known
liability exactly at maturity:

    W_0 = L*P(0,7)
"""
function lock_cost(liability::Real, seven_period_zero_price::Real)::Float64
    # TODO: Translate the displayed equation into one Julia expression.
    throw("lock_cost is not implemented yet");
end

"""
    terminal_wealth(initial_value::Real, growth_factors::AbstractVector) -> Float64

Return terminal wealth after rolling the complete sequence of one-period positions:

    W_7 = W_0*product(G_k)
"""
function terminal_wealth(initial_value::Real,
    growth_factors::AbstractVector)::Float64
    # TODO: Use `prod(...)` to multiply the supplied period growth factors.
    throw("terminal_wealth is not implemented yet");
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

