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

# 10x faster alternative for Part 2 =================================

in_ws_side(ij::CI{2}) = ij[1] == 71 || ij[2] == 1
in_en_side(ij::CI{2}) = ij[1] == 1 || ij[2] == 71

@enum CellStatus Empty Obstacle ObsWS ObsEN

const dirs8 = (CI(0, 1), CI(1, 0), CI(0, -1), CI(-1, 0), CI(1, 1), CI(-1, -1), CI(1, -1), CI(-1, 1))

function add_byte!(M, ij)
    M[ij] = if in_ws_side(ij)
        ObsWS
    elseif in_en_side(ij)
        ObsEN
    else
        Obstacle
    end
    for dir in dirs8
        new_ij = ij + dir
        new_ij in CIs(M) || continue
        if M[new_ij] ∈ (ObsWS, ObsEN)
            M[ij] = M[new_ij]
            propagate!(M, ij) && return true
        end
    end
    false
end

function propagate!(M, ij)
    value = M[ij]
    for dir in dirs8
        new_ij = ij + dir
        new_ij in CIs(M) || continue
        if M[new_ij] == Obstacle
            M[new_ij] = value
            propagate!(M, new_ij) && return true
        elseif M[new_ij] ∉ (Empty, value) # ie it's ObsWS or ObsEN, whichever is not value
            return true
        end
    end
    false
end


function solve_2(byte_list)
    grid = Matrix{CellStatus}(undef, (71, 71))
    grid .= Empty
    for (x, y) in byte_list
        ij = CI(x + 1, y + 1)
        add_byte!(grid, ij) && return (x, y)
    end
    @show grid
end

parse_input() |> solve_2

using BenchmarkTools

bl = parse_input()
@benchmark solve_2(bl)