include("Include.jl"); # supplied paths, support functions, Statistics, and Test
include(joinpath(_PATH_TO_SRC, "Advanced.jl")); # student Advanced-track expressions
include(joinpath(_ROOT, "test", "Rubric.jl")); # independent-check evaluator
include(joinpath(_ROOT, "test", "public_advanced_tests.jl")); # public checks

results = evaluate_public_checks(advanced_public_checks());
print_public_test_report(results, "PS1 Advanced Track");
all(result -> result.passed, results) || error("some public tests failed");

