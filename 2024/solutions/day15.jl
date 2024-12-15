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
        positions_to_shift = [[robot]]
        while true
            next_positions = CI{2}[]
            for pos ∈ last(positions_to_shift)
                next = pos + m
                if M[next] == '#'
                    @goto next_move
                elseif M[next] == '.'
                    continue
                end
                next ∈ next_positions || push!(next_positions, next)
                if abs(m.I[1]) == 1 && M[next] ∈ ('[', ']')
                    side = next + box_side(M[next])

                    side ∈ next_positions || push!(next_positions, side)
                end

            end
            isempty(next_positions) && @goto apply_move
            push!(positions_to_shift, next_positions)
        end
        @label apply_move
        while !isempty(positions_to_shift)
            next_positions = pop!(positions_to_shift)
            for pos ∈ next_positions
                M[pos], M[pos+m] = M[pos+m], M[pos]
            end
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