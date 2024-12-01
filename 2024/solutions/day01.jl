
function parse_input(input="2024/inputs/day01.txt")
    lists = (Int64[], Int64[])
    for line ∈ eachline(input)
        terms = split(line, "   ")
        foreach(zip(terms, lists)) do (t, l)
            push!(l, parse(Int64, t))
        end
    end
    lists
end

function solve_p1(lists)
    left, right = lists
    sort!(left)
    sort!(right)
    sum(zip(left, right)) do (l, r)
        abs(l - r)
    end
end

function solve_p2(lists)
    left, right = lists
    sum(left) do x
        count(==(x), right) * x
    end
end

parse_input() |> solve_p1 |> println
parse_input() |> solve_p2 |> println

# ========= faster P2 =========
# Caching duplicated results does not seem to improve performance

function solve_p2_alt(lists)
    left, right = lists
    sort!(right)
    sum(left) do x
        length(searchsorted(right, x))
    end
end

parse_input() |> solve_p2_alt |> println

using Chairmarks

@b parse_input() solve_p2
@b parse_input() solve_p2_alt