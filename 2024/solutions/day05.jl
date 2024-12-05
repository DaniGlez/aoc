function read_input(source="2024/inputs/day05.txt")
    rules = NTuple{2,Int}[]
    updates = Vector{Int}[]
    for line ∈ eachline(source)
        if '|' ∈ line
            before, after = parse.(Int64, split(line, '|'))
            push!(rules, (before, after))
        elseif ',' ∈ line
            push!(updates, parse.(Int, split(line, ',')))
        end
    end
    rules, updates
end


function is_well_sorted(rules, update)
    for (i_before, i_after) ∈ rules
        j_before, j_after = findfirst(==(i_before), update), findfirst(==(i_after), update)
        (isnothing(j_before) || isnothing(j_after)) && continue
        j_before > j_after && return false
    end
    true
end

function sort_with_rules!(rules::Vector, update)
    while !is_well_sorted(rules, update)
        for (i_before, i_after) ∈ rules
            j_before, j_after = findfirst(==(i_before), update), findfirst(==(i_after), update)
            (isnothing(j_before) || isnothing(j_after)) && continue
            if j_before > j_after
                update[j_before], update[j_after] = update[j_after], update[j_before]
            end
        end
    end
    nothing
end

function middle(update)
    n = length(update)
    @assert isodd(n)
    update[n÷2+1]
end

function p1(rules, updates)
    sum(updates) do update
        is_well_sorted(rules, update) ? middle(update) : 0
    end
end

function p2(rules, updates)
    sum(updates) do update
        is_well_sorted(rules, update) ? 0 : begin
            sort_with_rules!(rules, update)
            middle(update)
        end
    end
end

p1(read_input()...) |> println
p2(read_input()...) |> println