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

Return `true` when all three marked answer blocks contain text and no TODO markers.
This checks structure only; the teaching team reviews the substance of each answer.
"""
function response_is_complete(path::String)::Bool
    isfile(path) || return false;
    text = read(path, String);
    return all(1:3) do index
        pattern = Regex("<!-- answer-$(index):start -->(.*?)<!-- answer-$(index):end -->", "s");
        blocks = collect(eachmatch(pattern, text));
        length(blocks) == 1 || return false;
        answer = strip(replace(blocks[1].captures[1], r"<!--.*?-->"s => ""));
        !isempty(answer) && occursin(r"[\p{L}\p{N}]", answer) &&
            !occursin(r"\bTODO\b"i, answer);
    end;
end


"""
    rubric_score(results; tests_ran, completion) -> Int

Apply the course 0-to-4 rubric. "Most" means strictly more than half of the public tests.
Set `completion=true` only after the teaching team accepts all applicable requirements.
The local checker reports pending review when all numerical checks pass.
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
    :build_bill,
    :build_note,
    :reprice_note,
];

const ADVANCED_DOCUMENTED_FUNCTIONS = [
    :build_bill,
    :build_note,
    :reprice_note,
    :compare_strategies,
];
