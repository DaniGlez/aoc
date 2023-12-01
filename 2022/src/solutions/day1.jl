using Pipe

# part 1 --------
proc_chunk(chunk) = @pipe split(chunk, '\n') .|> parse(Int64, _) |> sum

open("src/inputs/day1.txt") do f
    txt = read(f, String)
    split(txt, "\n\n") .|> proc_chunk |> maximum
end

# part 2 --------
open("src/inputs/day1.txt") do f
    txt = read(f, String)
    cals_sorted = split(txt, "\n\n") .|> proc_chunk |> sort
    sum(cals_sorted[end-2:end])
end

# ====== compact version =======

# part 1
parse_d1() = (@pipe readchomp("src/inputs/day1.txt") |> split(_, "\n\n")) .|> proc_chunk
parse_d1() |> maximum |> println

# part 2
cals = parse_d1()
partialsort!(cals, 1:3; rev=true)
sum(cals[1:3]) |> println