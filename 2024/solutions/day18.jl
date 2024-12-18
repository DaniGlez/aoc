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

function part_2(byte_list)
    idx = findfirst(eachindex(byte_list)) do i
        solve(@view byte_list[1:i]) == typemax(Int64)
    end
    join(byte_list[idx], ',')
end

part_2(parse_input()) |> println