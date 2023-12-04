function score_line(line; scoring_func=(l -> l > 0 ? 2^(l - 1) : 0))
    winning_str, own_nos = split(split(line, ':')[2], '|')
    winning = map(i -> winning_str[i-1:i], 3:3:length(winning_str))
    l = 3:3:length(own_nos) |> filter(i -> own_nos[i-1:i] ∈ winning) |> length
    scoring_func(l)
end

sum(score_line, eachline("2023/inputs/input04.txt"))

# ------ Part 2 ------
function total_scratchcards(path)
    ub = 256
    copies = ones(Int64, ub)
    total = 0
    for (i, line) ∈ enumerate(eachline(path))
        n = copies[i]
        points = score_line(line; scoring_func=identity)
        copies[i+1:min(i + points, ub)] .+= n
        total += n
    end
    total
end

total_scratchcards("2023/inputs/input04.txt")
