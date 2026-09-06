# Local check-and-package helper. Run from the extracted assignment folder:
#
#   julia --project=. --startup-file=no check_submission.jl

import Dates # local timestamp written to the submission manifest
using SHA    # SHA-256 fingerprints of the submitted source and response files

println("""
==================== important ====================
This script checks your work, displays your financial results, and prepares MANIFEST.txt.
It does NOT upload anything to Canvas.
You must still create a ZIP archive and upload it through Canvas yourself.
""");

const _CHECK_ROOT = @__DIR__;
include(joinpath(_CHECK_ROOT, "test", "Rubric.jl"));

# Validate the track and load supplied checks before loading student functions -
const _CHECK_SETUP = let
    try
        track = lowercase(strip(read(joinpath(_CHECK_ROOT, "TRACK.txt"), String)));
        track ∈ ("standard", "advanced") || throw(ArgumentError(
            "TRACK.txt must contain exactly `standard` or `advanced`"));
        include(joinpath(_CHECK_ROOT, "Include.jl"));
        include(joinpath(_CHECK_ROOT, "reports", "Finance.jl"));
        include(joinpath(_CHECK_ROOT, "test", "public_$(track)_tests.jl"));
        checks = track == "standard" ? standard_public_checks() : advanced_public_checks();
        (track = track, checks = checks, detail = "");
    catch caught
        (track = "unavailable", checks = NamedTuple[], detail = sprint(showerror, caught));
    end
end;

# Load at top level so the student's methods are available when main runs -
const _CHECK_SOURCE = let
    if !isempty(_CHECK_SETUP.detail)
        (tests_ran = false, detail = _CHECK_SETUP.detail);
    else
        try
            include(joinpath(_CHECK_ROOT, "src", titlecase(_CHECK_SETUP.track)*".jl"));
            (tests_ran = true, detail = "");
        catch caught
            (tests_ran = false, detail = sprint(showerror, caught));
        end
    end
end;

"""
    write_submission_fingerprints(io, root, track) -> Nothing

Record regular source files recursively, TRACK.txt, and the selected discussion-question file.
Missing required files are recorded explicitly so incomplete work can still be packaged.
"""
function write_submission_fingerprints(io::IO, root::String, track::String)::Nothing
    files = [joinpath(root, "TRACK.txt")];
    source_path = joinpath(root, "src");
    if isdir(source_path)
        for (directory, _, names) ∈ walkdir(source_path)
            append!(files, [joinpath(directory, name) for name ∈ names
                if isfile(joinpath(directory, name))]);
        end
    end
    if track ∈ ("standard", "advanced")
        append!(files, [joinpath(source_path, titlecase(track)*".jl"),
            joinpath(root, "responses", titlecase(track)*".md")]);
    end
    for file ∈ sort(unique(files))
        relative_path = replace(relpath(file, root), '\\' => '/'); # same manifest paths on Windows and macOS
        if isfile(file)
            println(io, bytes2hex(open(sha256, file)), "  ", relative_path);
        else
            println(io, "MISSING  ", relative_path);
        end
    end
    return nothing;
end

"""
    main() -> Nothing

Run the selected checks, display financial results, and write MANIFEST.txt.
All-passing numerical work remains pending human completion review; this is local feedback.
"""
function main()::Nothing
    # Evaluate each check, including failures caused by an unfinished task -
    track = _CHECK_SETUP.track;
    tests_ran = _CHECK_SOURCE.tests_ran;
    results = tests_ran ? evaluate_public_checks(_CHECK_SETUP.checks) :
        failed_public_checks(_CHECK_SETUP.checks, _CHECK_SOURCE.detail);
    print_public_test_report(results, "PS1 $(titlecase(track)) Track");
    tests_ran || println("\nSetup/source error: ", _CHECK_SOURCE.detail);
    passed = count(result -> result.passed, results);
    all_passed = tests_ran && !isempty(results) && passed == length(results);

    # These are mechanical checks; the instructor assesses the quality of the work -
    documented = tests_ran && code_is_documented(track == "standard" ?
        STANDARD_DOCUMENTED_FUNCTIONS : ADVANCED_DOCUMENTED_FUNCTIONS);
    answers_present = track ∈ ("standard", "advanced") && response_is_complete(
        joinpath(_CHECK_ROOT, "responses", titlecase(track)*".md"));
    feedback = all_passed ? "pending completion review" : string(
        rubric_score(results; tests_ran = tests_ran, completion = false));
    status = !tests_ran ? "TESTS COULD NOT RUN" :
        all_passed && documented && answers_present ? "READY TO PACKAGE" : "CHECKS NEED ATTENTION";

    # Write the submission record even when the selected solution cannot run -
    manifest_path = joinpath(_CHECK_ROOT, "MANIFEST.txt");
    open(manifest_path, "w") do io
        println(io, "PS1 CHEME 5660 Fall 2026 submission manifest");
        println(io, "generated: ", Dates.now());
        println(io, "track: ", track);
        println(io, "tests ran: ", tests_ran);
        println(io, "public tests passed: $(passed)/$(length(results))");
        println(io, "required function docstrings present: ", documented);
        println(io, "all three answer blocks contain text without TODO markers: ", answers_present);
        println(io, "local rubric feedback: ", feedback);
        println(io, "status: ", status);
        isempty(_CHECK_SOURCE.detail) || println(io, "setup/source error: ", _CHECK_SOURCE.detail);
        write_submission_fingerprints(io, _CHECK_ROOT, track);
    end

    # Display the student's calculations for the discussion questions -
    if tests_ran
        try
            rows = track == "standard" ? standard_report_rows() : advanced_report_rows();
            print_finance_report(rows, "PS1 $(titlecase(track)) Financial Results");
            if track == "advanced"
                print_sequence_comparison(_CHECK_ROOT);
            end
        catch caught
            println("\nFinancial results unavailable: ", sprint(showerror, caught));
        end
    else
        println("\nFinancial results unavailable until the setup/source error is fixed.");
    end

    # Give feedback appropriate to the current submission -
    println("\n==================== submission summary ====================");
    println("track: ", track);
    println("public tests: $(passed)/$(length(results)) passed");
    println("required function docstrings present: ", documented);
    println("all three answer blocks contain text without TODO markers: ", answers_present);
    println("local rubric feedback: ", feedback);
    println("Status: ", status);
    println("wrote ", manifest_path);
    if all_passed
        println("All numerical checks passed. Documentation and responses await teaching-team review.");
        println("A final 4 requires acceptance of every applicable completion requirement in RUBRIC.md.");
    end
    if !documented || !answers_present
        println("Keep the required docstrings and answer all three prompts inside their marked blocks.");
    end
    if status != "READY TO PACKAGE"
        println("Review the reported issues, fix as much as you can, and run this checker again.");
        println("Deadline safeguard: submit your current readable work even if checks still fail.");
        println("Do not miss the initial deadline solely because the tests cannot run or do not all pass.");
    end
    println("""

This script has NOT uploaded anything to Canvas.

Canvas submission steps:
1. Zip the whole problem-set folder (the folder holding this script):
   - macOS: right-click the folder in Finder and choose "Compress".
   - Windows: right-click the folder and choose "Send to" -> "Compressed (zipped) folder".
2. Rename the ZIP to CHEME-5660-PS1-<your netid>.zip.
   Replace the entire <your netid> placeholder, including the angle brackets,
   with your actual NetID (for example, CHEME-5660-PS1-abc123.zip).
3. Upload the ZIP to the PS1 assignment on Canvas before the initial deadline.

Eligible revisions: return to the same Canvas assignment, select New Attempt,
and upload the revised ZIP. Revisions may be labeled late; this creates no penalty
under the infinite-revision policy. The highest score is retained.
""");
    return nothing;
end

main();
