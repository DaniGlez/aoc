# Sourced from Gunnar Farnebäck's code under the MIT license
# https://github.com/GunnarFarneback/AdventOfCode.jl/blob/master/aoc.jl

using Downloads: download
using BenchmarkTools

function create_template_if_missing(filename)
    isfile(filename) && return
    write(
        filename,
        """function part1(input)
           end
           function part2(input)
           end"""
    )
end

args = copy(ARGS)
benchmark_arg = filter(startswith("--benchmark"), args)
filter!(!startswith("--benchmark"), args)
length(args) >= 2 || error("Usage: julia aoc.jl YEAR DAY [TEST] [EXTRA_ARGS] [--benchmark=SUFFIX]")
year, day = args[1:2]
test = length(args) > 2
input_file = joinpath(@__DIR__, year, "input", "day$(day)")
if !isfile(input_file)
    mkpath(dirname(input_file))
    println("Downloading input for $year day $day.")
    session_cookie_file = joinpath(@__DIR__, "session_cookie")
    if isfile(session_cookie_file)
        session_cookie = read(session_cookie_file, String)
        download("https://adventofcode.com/$(year)/day/$(day)/input",
            input_file,
            headers=Dict("cookie" => "session=$(session_cookie)"))
    else
        println("No session cookie available. Download the input file manually and save it to $(input_file)")
    end
end
code_filename = "day$(day).jl"
create_template_if_missing(joinpath(@__DIR__, year, code_filename))
if !isempty(benchmark_arg) && occursin("=", only(benchmark_arg))
    suffix = last(split(only(benchmark_arg), "="))
    code_filename = "day$(day)$(suffix).jl"
end
include(joinpath(@__DIR__, year, code_filename))
if test
    input_file *= args[3]
end
for part in (part1, part2)
    part == part2 && println()
    print("Part ", last(string(part)), ": ")
    test && print(args[3])
    println()
    data = read(input_file)
    println(part(IOBuffer(data), args[4:end]...))
    if !isempty(benchmark_arg)
        length(args) < 4 || error("EXTRA_ARGS are not supported for benchmarking (due to interference with measurement).")
        @btime $(part)(input) setup = (input = IOBuffer($data)) evals = 1
    end
end