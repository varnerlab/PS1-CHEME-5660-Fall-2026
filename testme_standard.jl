include("Include.jl"); # course package, supplied paths, support functions, and Test
include(joinpath(_PATH_TO_SRC, "Standard.jl")); # student Standard-track package calls
include(joinpath(_ROOT, "test", "Rubric.jl")); # independent-check evaluator
include(joinpath(_ROOT, "test", "public_standard_tests.jl")); # public checks

results = evaluate_public_checks(standard_public_checks());
print_public_test_report(results, "PS1 Standard Track");
all(result -> result.passed, results) || error("some public tests failed");

