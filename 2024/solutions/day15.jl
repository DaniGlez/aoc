const CI = CartesianIndex
const CIs = CartesianIndices

const char2dir = Dict('^' => CI(-1, 0), 'v' => CI(1, 0), '<' => CI(0, -1), '>' => CI(0, 1))

function parse_input(filename="2024/inputs/day15.txt")
    chunks = split(read(filename, String), "\n\n")
    M = permutedims(stack(collect.(split.(chunks[1], '\n'))))
    moves = collect(Iterators.flatten([(c -> char2dir[c]).(collect(ch)) for ch in split(chunks[2], '\n')]))
    M, moves
end

const p2_map = Dict(
    '#' => "##",
    '.' => "..",
    'O' => "[]",
    '@' => "@."
)

box_side(c) = c == '[' ? CI(0, 1) : CI(0, -1)

widen(M) = permutedims(stack(
    map(eachrow(M)) do row
        join(map(c -> p2_map[c], row))
    end
))

function solve(M, moves)
    robot = findfirst(==('@'), M)
    for m ∈ moves
        positions_to_shift = CI{2}[]
        candidates = [robot]
        while !isempty(candidates)
            pos = popfirst!(candidates)
            push!(positions_to_shift, pos)
            next = pos + m
            if M[next] == '#'
                @goto next_move
            elseif M[next] == '.'
                continue
            end

            next ∈ candidates || push!(candidates, next)
            if abs(m.I[1]) == 1 && M[next] ∈ ('[', ']')
                side = next + box_side(M[next])
                side ∈ candidates || push!(candidates, side)
            end
        end
        while !isempty(positions_to_shift)
            pos = pop!(positions_to_shift)
            M[pos], M[pos+m] = M[pos+m], M[pos]
        end
        robot += m
        @label next_move
    end
    sum(CIs(M)) do ci
        gps = (ci.I[1] - 1, ci.I[2] - 1)
        M[ci] ∈ ('[', 'O') ? (100gps[1] + gps[2]) : 0
    end
end


begin
    M, moves = parse_input()
    solve(copy(M), moves) |> println
    solve(widen(M), moves) |> println
end