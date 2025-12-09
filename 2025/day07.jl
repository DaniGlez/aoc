manifold_diagram = collect.(eachline("2025/inputs/day07.txt"))
starting_position = findfirst(isequal('S'), first(manifold_diagram))

begin
    current = Set([starting_position])
    splits = 0
    for i ∈ 2:length(manifold_diagram)
        line = manifold_diagram[i]
        next = Set{Int64}()
        for pos ∈ current
            if line[pos] == '.'
                push!(next, pos)
            elseif line[pos] == '^'
                push!(next, pos - 1)
                push!(next, pos + 1)
                splits += 1
            end
        end
        current = next
    end
    splits
end

function count_timelines(manifold_diagram, row, cols)
    row == length(manifold_diagram) && return sum(values(cols))
    next_cols = Dict{Int64,Int64}()
    line = manifold_diagram[row]
    for (pos, count) ∈ cols
        if line[pos] == '.'
            next_cols[pos] = get(next_cols, pos, 0) + count
        elseif line[pos] == '^'
            next_cols[pos-1] = get(next_cols, pos - 1, 0) + count
            next_cols[pos+1] = get(next_cols, pos + 1, 0) + count
        end
    end
    count_timelines(manifold_diagram, row + 1, next_cols)
end

count_timelines(manifold_diagram, 2, Dict(starting_position => 1))