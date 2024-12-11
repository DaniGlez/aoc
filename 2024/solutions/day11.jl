const NO_STONE = -1

stones = split(readlines("2024/inputs/day11.txt") |> only, " ") .|> x -> parse(Int, x)

number_of_digits(x) = floor(Int, log10(x)) + 1

function blink(stone::Integer)
    stone == 0 && return (1, NO_STONE)
    n = number_of_digits(stone)
    iseven(n) && return divrem(stone, 10^(n ÷ 2))
    (stone * 2024, NO_STONE)
end

function solve(stones, n)
    d = Dict{Int64,Int64}()
    for s ∈ stones
        d[s] = 1
    end
    for _ in 1:n
        d_n = Dict{Int64,Int64}()
        for (s, n) ∈ d
            for s2 ∈ blink(s)
                s2 == NO_STONE && continue
                if haskey(d_n, s2)
                    d_n[s2] += n
                else
                    d_n[s2] = n
                end
            end
        end
        d = d_n
    end
    sum(values(d))
end

solve(stones, 25)
solve(stones, 75)