const CI = CartesianIndex
const CIs = CartesianIndices
const ENWS = (CI(0, 1), CI(1, 0), CI(0, -1), CI(-1, 0))

M = permutedims(stack(collect.(readlines("2024/inputs/day20.txt"))))

function dequeue!(d::Dict)
    v = minimum(values(d))
    for k in keys(d)
        if d[k] == v
            delete!(d, k)
            return k, v
        end
    end
end

function solve!(M, distances, from, to, cheat=CI(-1, -1))
    distances .= typemax(eltype(distances))
    origin = findfirst(==(from), M)
    destination = findfirst(==(to), M)
    distance[origin] = 0
    ij = origin
    while true
        for step in ENWS
            if distance[ij+step] > distance[ij] + 1
                distance[ij+step] = distance[ij] + 1
                ij = ij + step
                break
            end
        end
        ij == destination && break
    end
    distance[destination]
end

function p1(M, distances)
    count(CIs(M)) do ij
        M[ij] == '#' && cheat(M, distances, ij) >= 100
    end
end



begin
    M = permutedims(stack(collect.(readlines("2024/inputs/day20.txt"))))
    distance_max = solve(M)
    count(CIs(M)) do ij
        M[ij] == '#' && distance_max - solve(M, ij) >= 100
    end |> println
end

map(CIs(M)) do ij
    M[ij] == '#' ? distance_max - solve(M, ij) : 0
end


function solve_dist(M, from)
    distance = ones(Int, size(M)) .* typemax(Int64)
    frontier = Dict{CI{2},Int64}()
    origin = findfirst(==(from), M)
    distance[origin] = 0
    enqueue!(frontier, origin => 0)
    while !isempty(frontier)
        ij = dequeue!(frontier)
        for dir in ENWS
            new_ij = ij + dir
            new_ij in CartesianIndices(M) || continue
            M[ij] == '#' && continue
            if distance[new_ij] > distance[ij] + 1
                distance[new_ij] = distance[ij] + 1
                enqueue!(frontier, new_ij => distance[new_ij])
            end
        end
    end
    distance
end

function add_in_opt!(M, distance, in_optipath, ij)
    push!(in_optipath, ij)
    for dir in ENWS
        new_ij = ij + dir
        new_ij in CartesianIndices(M) || continue
        if distance[new_ij] == distance[ij] - 1
            add_in_opt!(M, distance, in_optipath, new_ij)
        end
    end
end

l1(a, b) = abs(a.I[1] - b.I[1]) + abs(a.I[2] - b.I[2])

function cheats100(M, dist_from_end, dist_from_start, d_opt, ij, advantage)
    d_ij = dist_from_end[ij]
    count(CIs(M)) do ij_start
        d_cheat = l1(ij_start, ij)
        M[ij_start] ∈ ('.', 'S') &&
            d_cheat <= 20 &&
            d_opt - (d_ij + d_cheat + dist_from_start[ij_start]) >= advantage
    end
end

begin
    M = permutedims(stack(collect.(readlines("2024/inputs/day20.txt"))))
    dist_from_end = solve_from(M, 'E')
    dist_from_start = solve_from(M, 'S')
    d_opt = dist_from_end[findfirst(==('S'), M)]
    @assert d_opt == dist_from_start[findfirst(==('E'), M)]
    check_queue = Dict{CI{2},Int64}()
    enqueue!(check_queue, findfirst(==('E'), M) => 0)
    cheats = 0
    while !isempty(check_queue)
        ij = dequeue!(check_queue)
        cheats += cheats100(M, dist_from_end, dist_from_start, d_opt, ij, 100)
        for dir in ENWS
            new_ij = ij + dir
            new_ij in CartesianIndices(M) || continue
            M[new_ij] == '#' && continue
            if dist_from_end[new_ij] == dist_from_end[ij] + 1
                enqueue!(check_queue, new_ij => dist_from_end[new_ij])
            end
        end
    end
    cheats
end



