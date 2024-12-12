M = permutedims(stack(collect.(readlines("2024/inputs/day12.txt"))))

const CI = CartesianIndex
const CIs = CartesianIndices

const steps = [
    CI(1, 0),
    CI(0, 1),
    CI(-1, 0),
    CI(0, -1)
]

function perimeter(area, ::Val{1})
    sum(area) do xy
        sum(steps) do step
            xy + step ∈ area ? 0 : 1
        end
    end
end

function expand_area!(M, visited, area)
    c, s = area
    v = Vector{CI{2}}()
    push!(v, only(s))
    while !isempty(v)
        xy = pop!(v)
        for step ∈ steps
            next = xy + step
            if next ∉ CIs(M) || visited[next] || M[next] != c
                continue
            else
                visited[next] = true
                push!(s, next)
                push!(v, next)
            end
        end
    end
end

function solve(M, part)
    areas = Vector{Tuple{Char,Set{CI{2}}}}()
    visited = zeros(Bool, size(M))
    for x ∈ CIs(M)
        visited[x] == true && continue
        visited[x] = true
        for area ∈ areas
            c, s = area
            M[x] == c && any(Δ -> x + Δ ∈ s, steps) && begin
                    push!(s, x)
                    @goto no_new_area
                end
        end
        new_area = Set{CI{2}}()
        push!(new_area, x)
        push!(areas, (M[x], new_area))
        expand_area!(M, visited, areas[end])
        @label no_new_area
    end
    sum(areas) do (_, points)
        perimeter(points, part) * length(points)
    end
end

const facings = steps

function perimeter(area, ::Val{2})
    edges = Dict{CI{2},Vector{Vector{CI{2}}}}()
    for facing ∈ facings
        edges[facing] = Vector{Vector{CI{2}}}()
    end
    for pos ∈ area
        for facing ∈ facings
            pos + facing ∉ area || continue
            for edge ∈ edges[facing]
                pos ∈ edge && @goto no_new_edge
            end
            add_edge!(area, edges, pos, facing)
            @label no_new_edge
        end
    end
    sum(length, values(edges))
end

function add_edge!(area, edges, pos, facing)
    search_direction = CI(facing.I[2], facing.I[1])
    edge = [pos]
    for s_d ∈ (search_direction, -search_direction)
        k = 1
        while true
            next = pos + s_d * k
            next ∈ area || break
            next + facing ∈ area && break
            push!(edge, next)
            k += 1
        end
    end
    push!(edges[facing], edge)
end

solve(M, Val(1)) |> println
solve(M, Val(2)) |> println