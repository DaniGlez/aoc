const CI = CartesianIndex
const CIs = CartesianIndices

function parse_line(line)
    re = r"p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)"
    px, py, vx, vy = parse.(Int64, match(re, line).captures)
    return CI(px, py), CI(vx, vy)
end

parse_input(filename="2024/inputs/day14.txt") = parse_line.(eachline(filename))

function move(p, v, t=1; map_size=(101, 103))
    pf = p + v * t
    X, Y = map_size
    x = mod1(pf.I[1] + 1, X)
    y = mod1(pf.I[2] + 1, Y)
    CI(x, y)
end

function predict_quadrant(p, v, t; map_size=(101, 103))
    x, y = move(p, v, t; map_size=map_size).I
    X, Y = map_size
    Xₕ, Yₕ = X ÷ 2 + 1, Y ÷ 2 + 1
    (x == Xₕ || y == Yₕ) && return 5
    1 + 2 * (x ÷ Xₕ) + (y ÷ Yₕ)
end

function solve(data)
    counts = [0, 0, 0, 0, 0]
    for (p, v) in data
        q = predict_quadrant(p, v, 100)
        counts[q] += 1
    end
    return counts[1] * counts[2] * counts[3] * counts[4]
end

data = parse_input("2024/inputs/day14.txt")
solve(data)

const all_neighbours = [
    CI(-1, -1), CI(-1, 0), CI(-1, 1), CI(0, -1), CI(0, 1), CI(1, -1), CI(1, 0), CI(1, 1)
]

function top3_clusters(data, t)
    clusters = Int64[]
    s = Set([p for (p, v) ∈ data])
    while !isempty(s)
        p = pop!(s)
        cluster = Set([p])
        q = [p]
        while !isempty(q)
            p = popfirst!(q)
            for Δ in all_neighbours
                n = p + Δ
                if n ∈ s
                    push!(q, n)
                    delete!(s, n)
                    push!(cluster, n)
                end
            end
        end
        push!(clusters, length(cluster))
    end
    partialsort!(clusters, 1:3, rev=true)
    return prod(clusters[1:3])
end

begin
    using Plots
    Plots.plotly()
    data = parse_input("2024/inputs/day14.txt")
    N = 20_000
    t3 = zeros(Int64, N)
    for i in 1:N
        data = map(data) do (p, v)
            (move(p, v), v)
        end
        t3[i] = top3_clusters(data, i)
    end
    Plots.scatter(1:N, t3)
end