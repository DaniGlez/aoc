const CIs = CartesianIndices
const CI = CartesianIndex

adjacents(ci) = [
    ci + CI(-1, 0),
    ci + CI(1, 0),
    ci + CI(0, -1),
    ci + CI(0, 1),
    ci + CI(-1, -1),
    ci + CI(-1, 1),
    ci + CI(1, -1),
    ci + CI(1, 1),
]

begin
    M = permutedims(stack(collect.(readlines("pocs/ignore/inp04.txt"))))
    count(CIs(M)) do ci
        c = count(adjacents(ci)) do neighbor
            neighbor ∈ CIs(M) && M[neighbor] == '@'
        end
        if M[ci] == '@' && c < 4
            @show ci, c
            true
        else
            false
        end
    end
end

begin
    M = permutedims(stack(collect.(readlines("pocs/ignore/inp04.txt"))))
    rolls_removed = 0
    while true
        @show rolls_removed
        removed = false
        for ci ∈ CIs(M)
            M[ci] != '@' && continue
            c = count(adjacents(ci)) do neighbor
                neighbor ∈ CIs(M) && M[neighbor] == '@'
            end
            if c < 4
                removed = true
                rolls_removed += 1
                M[ci] = '.'
            end
        end
        removed || break
    end
    rolls_removed
end
