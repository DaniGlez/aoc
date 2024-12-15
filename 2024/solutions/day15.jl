const CI = CartesianIndex
const CIs = CartesianIndices

const char2dir = Dict('^' => CI(-1, 0), 'v' => CI(1, 0), '<' => CI(0, -1), '>' => CI(0, 1),
    '\n' => missing)

function parse_input(filename="2024/inputs/day15.txt")
    cmap, cmoves = split(read(filename, String), "\n\n")
    M = permutedims(stack(collect.(split.(cmap, '\n'))))
    moves = collect(skipmissing([char2dir[c] for c ∈ cmoves]))
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

is_vertical(m::CI{2}) = (m.I[2] == 0)

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
                @goto skip_move
            elseif M[next] == '.'
                continue
            end
            # next now contains a box
            next ∈ candidates || push!(candidates, next)
            if is_vertical(m) && M[next] ∈ ('[', ']')
                side = next + box_side(M[next])
                side ∈ candidates || push!(candidates, side)
            end
        end
        while !isempty(positions_to_shift)
            pos = pop!(positions_to_shift)
            M[pos], M[pos+m] = M[pos+m], M[pos]
        end
        robot += m
        @label skip_move
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