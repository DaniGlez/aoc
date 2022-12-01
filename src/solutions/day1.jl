using Pipe

# part 1

proc_chunk(chunk) = @pipe split(chunk, '\n') .|> parse(Int64, _) |> sum

open("src/inputs/day1.txt") do f
    txt = read(f, String)
    split(txt, "\n\n") .|> proc_chunk |> maximum
end

# part 2
open("src/inputs/day1.txt") do f
    txt = read(f, String)
    cals_sorted = split(txt, "\n\n") .|> proc_chunk |> sort
    sum(cals_sorted[end-2:end])
end
