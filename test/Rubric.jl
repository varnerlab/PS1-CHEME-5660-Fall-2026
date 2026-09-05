"""
    evaluate_public_checks(checks::Vector{NamedTuple}) -> Vector{NamedTuple}

Evaluate every public check independently. An exception in one calculation becomes one
failed check rather than preventing the remaining checks from running.
"""
function evaluate_public_checks(checks::AbstractVector{<:NamedTuple})::Vector{NamedTuple}

    results = NamedTuple[];
    for check ∈ checks
        passed = false;
        detail = "";
        try
            value = check.evaluate();
            passed = value === true;
            passed || (detail = "check returned $(repr(value))");
        catch error
            detail = sprint(showerror, error);
        end
        push!(results, (name = check.name, passed = passed, detail = detail));
    end

    return results;
end


"""
    failed_public_checks(checks, detail) -> Vector{NamedTuple}

Construct an all-failed result when the selected source file cannot be loaded and the
tests therefore cannot run.
"""
function failed_public_checks(checks::AbstractVector{<:NamedTuple},
    detail::String)::Vector{NamedTuple}
    return [(name = check.name, passed = false, detail = detail) for check ∈ checks];
end


"""
    print_public_test_report(results, title) -> Nothing

Display every check and a compact pass-count summary.
"""
function print_public_test_report(results::AbstractVector{<:NamedTuple},
    title::String)::Nothing

    println("\n", title);
    println(repeat("=", length(title)));
    for result ∈ results
        status = result.passed ? "PASS" : "FAIL";
        println("[", status, "] ", result.name);
        if !result.passed && !isempty(result.detail)
            println("       ", result.detail);
        end
    end

    passed = count(result -> result.passed, results);
    println("\npassed $(passed) of $(length(results)) public tests");
    return nothing;
end


"""
    code_is_documented(function_names::Vector{Symbol}) -> Bool

Return `true` when every required public function retains a Julia docstring.
"""
function code_is_documented(function_names::Vector{Symbol})::Bool
    metadata = Base.Docs.meta(Main); # docstrings registered in the current Julia module
    return all(function_names) do name
        binding = Base.Docs.Binding(Main, name);
        isdefined(Main, name) && haskey(metadata, binding)
    end;
end


"""
    response_is_complete(path::String) -> Bool

Return `true` when the selected finance-response file exists and contains no `TODO:`
markers. The teaching team reviews the substance of the responses before assigning a 4.
"""
function response_is_complete(path::String)::Bool
    return isfile(path) && !occursin("TODO:", read(path, String));
end


"""
    rubric_score(results; tests_ran, completion) -> Int

Apply the course 0-to-4 rubric. "Most" means strictly more than half of the public tests.
The returned score is provisional when `completion=true`; the teaching team still checks
the quality of the documentation and finance responses.
"""
function rubric_score(results::AbstractVector{<:NamedTuple};
    tests_ran::Bool, completion::Bool)::Int

    passed = count(result -> result.passed, results);
    total = length(results);

    if !tests_ran || passed == 0
        return 0;
    elseif 2*passed <= total
        return 1;
    elseif passed < total
        return 2;
    elseif !completion
        return 3;
    else
        return 4;
    end
end


const STANDARD_DOCUMENTED_FUNCTIONS = [
    :equivalent_growth_rate,
    :bill_price,
    :price_implied_growth_rate,
    :discount_factors,
    :present_value,
    :macaulay_duration,
    :modified_duration,
    :convexity,
    :price_change_fraction,
];

const ADVANCED_DOCUMENTED_FUNCTIONS = [
    :price_implied_growth_rate,
    :growth_factor,
    :lock_cost,
    :terminal_wealth,
    :funding_ratio,
    :shortfall,
    :funding_probability,
    :mean_shortfall,
    :maximum_shortfall,
    :funding_summary,
];
