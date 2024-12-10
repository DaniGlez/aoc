M = parse.(Int, permutedims(stack(collect.(readlines("2024/inputs/day10.txt")))))

const CI = CartesianIndex
const CIs = CartesianIndices

const steps = [
    CI(1, 0),
    CI(0, 1),
    CI(-1, 0),
    CI(0, -1)
]

function solve(M)
    trailheads = findall(==(0), M)
    out = sum(trailheads) do th
        reachable_nines = Set{CI}()
        p2 = add_reachable!(M, reachable_nines, th, 1)
        CI(length(reachable_nines), p2)
    end
    out.I
end

function add_reachable!(M, reachable, xy, z)
    sum(steps) do step
        next = xy + step
        if next ∉ CIs(M) || M[next] != z
            0
        elseif z == 9
            push!(reachable, next)
            1
        else
            add_reachable!(M, reachable, next, z + 1)
        end
    end
end

M = parse.(Int, permutedims(stack(collect.(readlines("2024/inputs/day10.txt")))))
solve(M) |> println