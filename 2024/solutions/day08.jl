const CI = CartesianIndex
const CIs = CartesianIndices

M = permutedims(stack(collect.(readlines("2024/inputs/day08.txt"))))

struct AntiNodeIterator # for p2
    source::CI{2}
    step::CI{2}
    grid::CartesianIndices{2,Tuple{Base.OneTo{Int64},Base.OneTo{Int64}}}
end

Base.iterate(iter::AntiNodeIterator) = (iter.source, 1)
function Base.iterate(iter::AntiNodeIterator, state)
    target = iter.source + state * iter.step
    target ∈ iter.grid ? (target, state + 1) : nothing
end

function solve(M; part)
    symbols = Set(M)
    delete!(symbols, '.')
    locs = Set{CI{2}}()
    for s ∈ symbols
        antennae = findall(==(s), M)
        for (i, a_i) ∈ enumerate(antennae)
            for a_j ∈ antennae[1:(i-1)]
                step = (a_i - a_j)
                if part == :p1
                    for a_n ∈ (a_i + step, a_j - step)
                        a_n ∈ CIs(M) && push!(locs, a_n)
                    end
                elseif part == :p2
                    for c ∈ (
                        AntiNodeIterator(a_i, step, CIs(M)),
                        AntiNodeIterator(a_j, -step, CIs(M))
                    )
                        for a_n in c
                            push!(locs, a_n)
                        end
                    end
                end
            end
        end
    end
    length(locs)
end

solve(M; part=:p1) |> println
solve(M; part=:p2) |> println