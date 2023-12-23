using Accessors
const CI = CartesianIndex
const N, E, S, W = CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1)
const NESW = (N, E, S, W)
const dirchars = ('^', '>', 'v', '<')
neighbours(ci::CI{2}) = map(Δ -> ci + Δ, (N, E, S, W))

fetch_map(path="2023/inputs/input23.txt") = stack(readlines(path) .|> collect, dims=1)

function can_step_into(M, x, y)
    y ∈ CartesianIndices(M) || return false
    M[y] == '#' && return false
    M[x] ∈ dirchars && return y - x == NESW[findfirst(==(M[x]), dirchars)]
    M[y] == '.' && return true
    y - x == NESW[findfirst(==(M[y]), dirchars)]
end

function max_path_p1(M, prev, x, n_steps)
    (h, w) = size(M)
    while true
        x == CI(h, w - 1) && return n_steps
        next = map(y -> y != prev && can_step_into(M, x, y), neighbours(x))
        if sum(next) > 1
            f = ((can_step, y),) -> can_step ? max_path_p1(M, x, y, n_steps + 1) : 0
            return maximum(f, zip(next, neighbours(x)))
        end
        n_steps += 1
        (prev, x) = (x, x + NESW[findfirst(next)])
    end
end

solve_p1(M) = max_path_p1(M, CI(0, 2), CI(1, 2), 0)
fetch_map() |> solve_p1

# ------ Part 2 ------
function patch_map(M)
    replacements = map(d -> d => '.', dirchars)
    replace(M, replacements...)
end

struct SymmetricKeyDict{K,V}
    d::Dict{K,V}
end

SymmetricKeyDict{K,V}() where {K,V} = SymmetricKeyDict(Dict{K,V}())

function Base.setindex!(skd::SymmetricKeyDict, value, key)
    skd.d[key] = value
    skd.d[reverse(key)] = value
end

Base.setindex!(skd::SymmetricKeyDict, value, k1, k2) = (skd[(k1, k2)] = value)
Base.getindex(skd::SymmetricKeyDict, key) = skd.d[key]
Base.getindex(skd::SymmetricKeyDict, i1, i2) = skd.d[(i1, i2)]
Base.keys(skd::SymmetricKeyDict) = keys(skd.d)

function build_graph(M)
    (h, w) = size(M)
    end_node = CI(h, w - 1)
    nodes = [CI(1, 2), end_node]
    distances = SymmetricKeyDict{NTuple{2,Int64},Int64}()
    build_graph!(nodes, distances, M, CI(1, 2), CI(2, 2))
    nodes, distances
end

function build_graph!(nodes, distances, M, entry_point, next_step)
    q = [(entry_point, next_step)]
    while !isempty(q)
        n_steps = 1
        x0, x1 = pop!(q)
        x, x_prev = x1, x0
        while true
            next = map(y -> y != x_prev && can_step_into(M, x, y), neighbours(x))
            if sum(next) != 1
                idx0 = findfirst(==(x0), nodes)
                idx = findfirst(==(x), nodes)
                if isnothing(idx)
                    push!(nodes, x)
                    distances[idx0, length(nodes)] = n_steps
                else
                    # if already found, no need to expand the node - just record distance
                    distances[idx0, idx] = n_steps
                    break
                end
                for (reachable, y) ∈ zip(next, neighbours(x))
                    reachable || continue
                    push!(q, (x, y))
                end
                break
            end
            n_steps += 1
            (x_prev, x) = (x, x + NESW[findfirst(next)])
        end
    end
end

get_other(i) = t -> t[1] == i ? t[2] : t[1]

function destinations_dict(distances, n)
    d = Dict{Int64,NTuple{4,Int64}}()
    for node_idx ∈ 1:n
        to = keys(distances) |> filter(k -> node_idx ∈ k) .|> get_other(node_idx) |> unique
        d[node_idx] = ntuple(i -> i <= length(to) ? to[i] : -1, 4)
    end
    d
end

function max_path(distances, destinations, available, start_idx, end_idx)
    available = @set available[start_idx] = false
    start_idx == end_idx && return 0
    next_from_start = destinations[start_idx]
    mx = -1
    for next ∈ next_from_start
        (next > 0 && available[next]) || continue
        d = max_path(distances, destinations, available, next, end_idx)
        isnothing(d) && continue
        mx = max(mx, d + distances[start_idx, next])
    end
    mx == -1 && return nothing
    mx
end

function solve_p2(M)
    nodes, distances = build_graph(M |> patch_map)
    n = length(nodes)
    destinations = destinations_dict(distances, n)
    available = (false, ntuple(_ -> true, n - 1)...)
    max_path(distances, destinations, available, 1, 2)
end

fetch_map() |> solve_p2
