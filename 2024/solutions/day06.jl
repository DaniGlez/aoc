const CI = CartesianIndex
const CIs = CartesianIndices

M = permutedims(stack(collect.(readlines("2024/inputs/day06.txt"))))

const rotate_right = Dict(CI(-1, 0) => CI(0, 1),
    CI(0, 1) => CI(1, 0),
    CI(1, 0) => CI(0, -1),
    CI(0, -1) => CI(-1, 0))

const DIRS = (CI(-1, 0), CI(0, 1), CI(1, 0), CI(0, -1))
const DIR_CHARS = ('^', '>', 'v', '<')

dir2char(d) = DIR_CHARS[findfirst(==(d), DIRS)]
char2dir(c) = DIRS[findfirst(==(c), DIR_CHARS)]
dir_idx(d::CartesianIndex) = findfirst(==(d), DIRS)
dir_idx(c::Char) = findfirst(==(c), DIR_CHARS)

const GUARD_IN_LOOP = -1

function solve(M, part; kwargs...)
    visited = falses((size(M)..., 4))
    solve!(M, part, visited; kwargs...)
end

function solve!(M, ::Val{part}, visited;
    start=nothing, direction=CI(-1, 0), obstacle_loc=CI(-1, -1)) where {part}
    visited .= false
    if part == :p2
        visited_next = copy(visited)
        acc_p2 = Set{CartesianIndex{2}}()
    end
    x = isnothing(start) ? findfirst(==('^'), M) : start
    visited[x, dir_idx(direction)] = true
    while true
        next = x + direction
        next ∉ CIs(M) && break
        if M[next] == '#' || next == obstacle_loc
            direction = rotate_right[direction]
        else
            if part == :p2
                visited_next .= visited
                out = solve!(M, Val(:p1), visited_next, start=x, direction=direction,
                    obstacle_loc=next)
                out == GUARD_IN_LOOP && push!(acc_p2, next)
            end
            d_idx = dir_idx(direction)
            visited[next, d_idx] && return GUARD_IN_LOOP
            visited[next, d_idx] = true
            x = next
        end
    end
    if part == :p1
        count(CartesianIndices(M)) do x
            any(@view visited[x, :])
        end
    elseif part == :p2
        length(acc_p2)
    end
end

# Part 1
solve_p1(M) = solve(M, Val(:p1);)
solve(M, Val(:p1)) |> println
solve(M, Val(:p2)) |> println