using DataStructures

fetch_map(path="2023/inputs/input17.txt") = parse.(Int64,
    stack(readlines(path) .|> collect, dims=1)
)

const CI = CartesianIndex

ci2(ci) = CI(ci.I[1], ci.I[2])
switch_z(ci3) = CI(ci3.I[1], ci3.I[2], 3 - ci3.I[3])

function next_moves(x::CI{3}, steps)
    s = ((0 .- steps)..., steps...)
    Δ = (x.I[3] == 1 ? CI(1, 0, 0) : CI(0, 1, 0))
    zip(switch_z.(x .+ s .* Δ), Δ .* sign.(s))
end

function running_cost(M, x3, y3, Δ3)
    y, Δx = ci2(y3), ci2(Δ3)
    x = ci2(x3) + Δx
    M[x] + (x == y ? 0 : running_cost(M, x, y, Δx))
end

function solve_map(M; steps=(1, 2, 3))
    (h, w) = size(M)
    V = ones(Int64, (h, w, 2)) * typemax(Int64)
    # on [:,:,1] you can only move up or down, on [:,:,2] left or right
    pq = PriorityQueue{CI{3},Int64}()
    enqueue!(pq, CI(1, 1, 1) => 0)
    enqueue!(pq, CI(1, 1, 2) => 0)
    V[1, 1, :] .= 0
    while !isempty(pq)
        x = dequeue!(pq)
        for (n, Δx) ∈ next_moves(x, steps)
            n ∈ CartesianIndices(V) || continue
            ΔV = running_cost(M, x, n, Δx)
            V[n] <= V[x] + ΔV && continue
            V[n] = V[x] + ΔV
            pq[n] = V[n]
        end
    end
    minimum(V[end, end, :])
end

fetch_map() |> solve_map |> println
solve_map(fetch_map(); steps=Tuple(4:10)) |> println