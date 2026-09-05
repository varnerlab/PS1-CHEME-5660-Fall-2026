# Check-and-package helper. Run from the repository root:
#
#   julia --project=. --startup-file=no submit.jl

import Dates # timestamp written to the submission manifest
using SHA    # SHA-256 digests used to identify the submitted source files

# Read and validate the student's declared track before loading track-specific code -
const _SUBMIT_ROOT = @__DIR__;
const _SUBMIT_TRACK = lowercase(strip(read(joinpath(_SUBMIT_ROOT, "TRACK.txt"), String)));
_SUBMIT_TRACK ∈ ("standard", "advanced") || throw(ArgumentError(
    "TRACK.txt must contain exactly `standard` or `advanced`"));

# Load the supplied support, rubric evaluator, and selected public checks -
include(joinpath(_SUBMIT_ROOT, "Include.jl"));
include(joinpath(_SUBMIT_ROOT, "test", "Rubric.jl"));
include(joinpath(_SUBMIT_ROOT, "test", "public_$(_SUBMIT_TRACK)_tests.jl"));
const _SUBMIT_CHECKS = _SUBMIT_TRACK == "standard" ?
    standard_public_checks() : advanced_public_checks();

# Load the student's source before defining main; this avoids Julia world-age issues -
const _SOURCE_LOAD_STATUS = let
    source_path = joinpath(_SUBMIT_ROOT, "src", titlecase(_SUBMIT_TRACK)*".jl");
    try
        include(source_path);
        (tests_ran = true, detail = "");
    catch error
        (tests_ran = false, detail = sprint(showerror, error));
    end
end;

function main()

    # Evaluate every public check independently so partial work receives visible credit -
    tests_ran = _SOURCE_LOAD_STATUS.tests_ran;
    results = tests_ran ? evaluate_public_checks(_SUBMIT_CHECKS) :
        failed_public_checks(
            _SUBMIT_CHECKS,
            "selected source file did not load: $(_SOURCE_LOAD_STATUS.detail)",
        );
    print_public_test_report(results, "PS1 $(titlecase(_SUBMIT_TRACK)) Track");

    # Check the non-numerical requirements that distinguish rubric scores 3 and 4 -
    documented_functions = _SUBMIT_TRACK == "standard" ?
        STANDARD_DOCUMENTED_FUNCTIONS : ADVANCED_DOCUMENTED_FUNCTIONS;
    code_documented = tests_ran && code_is_documented(documented_functions);
    response_path = joinpath(
        _SUBMIT_ROOT, "responses", titlecase(_SUBMIT_TRACK)*".md");
    response_complete = response_is_complete(response_path);
    completion = code_documented && response_complete;
    score = rubric_score(results; tests_ran = tests_ran, completion = completion);
    passed = count(result -> result.passed, results);

    # Record track selection, test counts, completion checks, and source fingerprints -
    manifest_path = joinpath(_SUBMIT_ROOT, "MANIFEST.txt");
    open(manifest_path, "w") do io
        println(io, "PS1 CHEME 5660 Fall 2026 submission manifest");
        println(io, "generated: ", Dates.now());
        println(io, "track: ", _SUBMIT_TRACK);
        println(io, "tests ran: ", tests_ran);
        println(io, "public tests passed: $(passed)/$(length(results))");
        println(io, "required functions documented: ", code_documented);
        println(io, "finance response placeholders completed: ", response_complete);
        println(io, "provisional rubric score: ", score);

        for file ∈ sort(readdir(joinpath(_SUBMIT_ROOT, "src"); join = true))
            digest = bytes2hex(open(sha256, file));
            println(io, digest, "  src/", basename(file));
        end
        if isfile(response_path)
            digest = bytes2hex(open(sha256, response_path));
            println(io, digest, "  responses/", basename(response_path));
        else
            println(io, "MISSING  responses/", basename(response_path));
        end
    end

    # Display the provisional rubric result and packaging instructions -
    println("\n==================== submission summary ====================");
    println("track: ", _SUBMIT_TRACK);
    println("public tests: $(passed)/$(length(results)) passed");
    println("required functions documented: ", code_documented);
    println("finance responses completed: ", response_complete);
    println("provisional rubric score: ", score);
    if score == 4
        println("A final score of 4 is assigned after the teaching team reviews documentation and responses.");
    end
    println("wrote ", manifest_path);
    println("""
Next steps:
1. Zip the complete problem-set folder.
2. Rename the archive to PS1-<your netid>.zip.
3. Upload the archive to the PS1 assignment on Canvas.
""");
end

main();
