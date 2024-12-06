const CI = CartesianIndex
const CIs = CartesianIndices

M = permutedims(reduce(hcat, (collect.(readlines("2024/inputs/day06.txt")))))

const rotate_right = Dict(CI(-1, 0) => CI(0, 1),
    CI(0, 1) => CI(1, 0),
    CI(1, 0) => CI(0, -1),
    CI(0, -1) => CI(-1, 0))

const dir2char = Dict(CI(-1, 0) => '^',
    CI(0, 1) => '>',
    CI(1, 0) => 'v',
    CI(0, -1) => '<')

function solve(M; obstacle_loc=CI(-1, -1), write=false)
    visited = falses(size(M))
    x = findfirst(==('^'), M)
    visited[x] = true
    direction = CI(-1, 0)
    while true
        next = x + direction
        next ∉ CIs(M) && break
        if M[next] == '#' || next == obstacle_loc
            direction = rotate_right[direction]
        else
            x = next
            visited[x] = true
            if write
                if M[x] == dir2char[direction]
                    return true
                end
                M[x] = dir2char[direction]
            end
        end
    end
    write && return false
    count(visited)
end

# Part 1
solve(M) |> println

# Part 2
count(CIs(M)) do obs
    M[obs] != '#' && solve(copy(M); obstacle_loc=obs, write=true)
end |> println

