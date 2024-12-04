const CI2 = CartesianIndex{2}

M = reduce(vcat, permutedims.(collect.(readlines("2024/inputs/day04.txt"))))
const XMAS = ('X', 'M', 'A', 'S')
const all_directions = [
    CI2(1, 0), CI2(0, 1), CI2(-1, 0), CI2(0, -1),
    CI2(1, 1), CI2(1, -1), CI2(-1, 1), CI2(-1, -1)
]

function solve_part_1(M)
    sum(all_directions) do direction
        count(CartesianIndices(M)) do s0
            idx = s0 .+ direction .* (0:3)
            all(i -> i ∈ CartesianIndices(M), idx) && all(XMAS .== M[idx])
        end
    end
end

solve_part_1(M) |> println

function solve_part_2(M)
    dir_pairs = (
        (CI2(1, -1), CI2(-1, 1)),
        (CI2(1, 1), CI2(-1, -1)),
    )
    d_flat = Iterators.flatten(dir_pairs) |> collect
    count(CartesianIndices(M)) do s0
        M[s0] == 'A' &&
            all(d -> d + s0 ∈ CartesianIndices(M), d_flat) && all(dir_pairs) do p
                w = (M[s0+p[1]], M[s0+p[2]])
                (w == ('M', 'S')) || (w == ('S', 'M'))
            end
    end
end

solve_part_2(M) |> println