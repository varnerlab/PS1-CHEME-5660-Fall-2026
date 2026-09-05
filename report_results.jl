# Display the financial results needed for the selected track's written responses -
# Run: julia --project=. --startup-file=no report_results.jl
include(joinpath(@__DIR__, "Include.jl"));
include(joinpath(@__DIR__, "reports", "Finance.jl"));
track = lowercase(strip(read(joinpath(@__DIR__, "TRACK.txt"), String)));
track ∈ ("standard", "advanced") || throw(ArgumentError(
    "TRACK.txt must contain exactly `standard` or `advanced`"));
include(joinpath(_PATH_TO_SRC, titlecase(track)*".jl"));
rows = track == "standard" ? standard_report_rows() : advanced_report_rows();
print_finance_report(rows, "PS1 $(titlecase(track)) Financial Results");
if track == "advanced"
    println("\nThe funding fraction and observed extremes describe 40 supplied model scenarios.");
    println("They are not real-world forecasts or bounds on all possible outcomes.");
end
