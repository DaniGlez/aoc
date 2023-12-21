const CI = CartesianIndex
const N, E, S, W = CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1)

fetch_map(path="2023/inputs/input21.txt") = stack(readlines(path) .|> collect, dims=1)

neighbours(ci::CI{2}) = map(Δ -> ci + Δ, (N, E, S, W))

function reach_n(M; steps=64)
    start = findfirst(==('S'), M)
    (h, w) = size(M)
    distances = Matrix{Int64}(undef, (h, w))
    distances .= typemax(Int64)
    distances[start] = 0
    for d ∈ 0:(steps-1)
        for x ∈ findall(==(d), distances)
            for n ∈ neighbours(x)
                n ∈ CartesianIndices(distances) || continue
                M[n] == '#' && continue
                distances[n] = min(distances[n], d + 1)
            end
        end
    end
    distances
end

solve_p1(M; steps=64) = count(in(0:2:steps), reach_n(M; steps=steps))

fetch_map() |> solve_p1
