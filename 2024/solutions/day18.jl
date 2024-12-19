function parse_input(filename="2024/inputs/day18.txt")
    map(eachline(filename)) do line
        chunks = split(line, ',')
        (parse(Int64, chunks[1]), parse(Int64, chunks[2]))
    end
end

parse_input()

const CI = CartesianIndex
const CIs = CartesianIndices
const ENWS = [CI(0, 1), CI(1, 0), CI(0, -1), CI(-1, 0)]

# Poor-man's priority queue
function dequeue!(d::Dict)
    v = minimum(values(d))
    for k in keys(d)
        if d[k] == v
            delete!(d, k)
            return k
        end
    end
end

function enqueue!(d::Dict, kv)
    k, v = kv
    d[k] = v
end

function solve(byte_list)
    grid = zeros(Bool, 71, 71)
    for (x, y) in byte_list
        grid[x+1, y+1] = true
    end
    distance = ones(Int, size(grid)) .* typemax(Int64)
    frontier = Dict{CI{2},Int64}()
    origin = CI(1, 1)
    destination = CI(71, 71)
    distance[origin] = 0
    enqueue!(frontier, origin => 0)
    while !isempty(frontier)
        ij = dequeue!(frontier)
        if distance[ij] > distance[destination]
            continue
        end
        for dir in ENWS
            new_ij = ij + dir
            new_ij in CartesianIndices(grid) || continue
            grid[new_ij] && continue
            if distance[new_ij] > distance[ij] + 1
                distance[new_ij] = distance[ij] + 1
                enqueue!(frontier, new_ij => distance[new_ij])
            end
        end
    end
    distance[destination]
end

solve(@view parse_input()[1:1024]) |> println

# Part 2 ====================================
# searchsortedlast does not work with maps :(

function binsearch(f, lo, hi)
    while hi - lo > 1
        mid = (lo + hi) ÷ 2
        if f(mid) > 0
            hi = mid
        else
            lo = mid + 1
        end
    end
    hi
end

function part_2(byte_list)
    reachable_boundary(n) = solve(@view byte_list[1:n]) + 1 - typemax(Int64)
    idx = binsearch(reachable_boundary, 1, length(byte_list))
    join(byte_list[idx], ',')
end

part_2(parse_input()) |> println

# Part 2 alt ================================
# slower :(((

is_neighbour(a::CI{2}, b::CI{2}) = all(abs.(a.I .- b.I) .<= 1)

in_ws_side(ij::CI{2}) = ij[1] == 70 || ij[2] == 0
in_en_side(ij::CI{2}) = ij[1] == 0 || ij[2] == 70

mutable struct Cluster
    touches_ws::Bool
    touches_en::Bool
    obstacles::Set{CI{2}}
end

merge_clusters(a::Cluster, b::Cluster) = Cluster(
    a.touches_ws || b.touches_ws,
    a.touches_en || b.touches_en,
    a.obstacles ∪ b.obstacles
)

function add_obstacle!(cluster::Cluster, ij::CI{2})
    any(obs -> is_neighbour(obs, ij), cluster.obstacles) || return false
    push!(cluster.obstacles, ij)
    cluster.touches_ws |= in_ws_side(ij)
    cluster.touches_en |= in_en_side(ij)
    true
end

blocks_path(cluster::Cluster) = cluster.touches_ws && cluster.touches_en

function solve_alt(byte_list)
    clusters = Cluster[]
    for (i, j) ∈ byte_list
        ij = CI(i, j)
        idxs = filter(eachindex(clusters)) do cluster_idx
            add_obstacle!(clusters[cluster_idx], ij)
        end
        if isempty(idxs)
            push!(clusters, Cluster(in_ws_side(ij), in_en_side(ij), Set([ij])))
        elseif length(idxs) > 1
            while length(idxs) > 1
                idx_del = pop!(idxs)
                cl_del = splice!(clusters, idx_del)
                clusters[last(idxs)] = merge_clusters(
                    clusters[last(idxs)], cl_del
                )
            end
        end
        any(blocks_path, clusters) && return ij
    end
end

printsol(ij::CI{2}) = join(ij.I, ',') |> println

parse_input() |> solve_alt |> printsol

@benchmark solve_alt(bl)