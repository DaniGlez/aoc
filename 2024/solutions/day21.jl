function parse_input(filename="2024/inputs/day21.txt")
    collect.(readlines(filename))
end

const CI = CartesianIndex
const CIs = CartesianIndices

const numpad = [
    '7' '8' '9'
    '4' '5' '6'
    '1' '2' '3'
    ' ' '0' 'A'
]

const position_in_numpad = Dict(numpad[ci] => ci for ci in CIs(numpad))

const dirpad = [
    ' ' '^' 'A'
    '<' 'v' '>'
]

const position_in_dirpad = Dict(dirpad[ci] => ci for ci in CIs(dirpad))

const char2move = Dict(
    '<' => CI(0, -1),
    '>' => CI(0, 1),
    '^' => CI(-1, 0),
    'v' => CI(1, 0),
)

const move2char = Dict(v => k for (k, v) in char2move)

position_to_move(x) = char2move[dirpad[x]]

const illegal_3state = (CI(0, 0), CI(0, 0), CI(0, 0))

# P1 with Dijkstra

function dequeue!(d::Dict)
    v = minimum(values(d))
    for k in keys(d)
        if d[k] == v
            delete!(d, k)
            return k, v
        end
    end
end

function plan_transition(from, to)
    start_state = (position_in_dirpad['A'], position_in_dirpad['A'], position_in_numpad[from])
    end_state = (position_in_dirpad['A'], position_in_dirpad['A'], position_in_numpad[to])
    S = ones(Int64, (2, 3, 2, 3, 4, 3)) * typemax(Int64)
    S[start_state...] = 0
    frontier = Dict(start_state => 0)
    while !isempty(frontier)
        state, current_value = dequeue!(frontier)
        if current_value > S[end_state...]
            continue
        end
        for move ∈ ('<', '>', '^', 'v', 'A')
            new_state = if move == 'A'
                push_a(state)
            else
                (state[1] + char2move[move], state[2], state[3])
            end
            if is_legal(new_state)
                if S[new_state...] > current_value + 1
                    S[new_state...] = current_value + 1
                    frontier[new_state] = current_value + 1
                end
            end
        end
    end
    S[end_state...]
end

function is_legal(state)
    D1, D2, N = state
    is_legal_directional(D1) && is_legal_directional(D2) && is_legal_numeric(N)
end

is_legal_directional(D) = D ∈ CIs(dirpad) && dirpad[D] != ' '
is_legal_numeric(N) = N ∈ CIs(numpad) && numpad[N] != ' '

function push_a(state::NTuple{3})
    D1, D2, N = state
    dirpad[D1] ∉ ('A', ' ') || return illegal_3state
    Δ2 = position_to_move(D1)
    if Δ2 == CI(0, 0)
        (D1, push_a((D2, N))...)
    else
        (D1, D2 + Δ2, N)
    end
end

function push_a(state::NTuple{2})
    D2, N = state
    dirpad[D2] ∉ ('A', ' ') || return illegal_3state
    Δ3 = position_to_move(D2)
    if Δ3 == CI(0, 0)
        (D2, push_a(N))
    else
        (D2, N + Δ3)
    end
end

push_a(::CI) = illegal_3state

function complexity(move)
    e_move = ['A', move...]
    l = sum(zip(e_move[1:end-1], e_move[2:end])) do (a, b)
        plan_transition(a, b) + 1
    end
    @show l
    l * parse(Int64, join(move[1:end-1]))
end

begin
    data = parse_input()
    sum(complexity, data)
end





using Memoize

plan_numeric(from::Char, to::Char) = plan_numeric(numeric_keypad[from], numeric_keypad[to])
function plan_numeric(from::CI, to::CI)
    Δi, Δj = (to - from).I
    v = Δi < 0 ? '^' : 'v'
    h = Δj < 0 ? '<' : '>'
    (v, abs(Δi)), (h, abs(Δj)), ('A', 1)
end

function move2seq(move)
    (v, nv), (h, nh), (a, n_a) = move
    [repeat([v], nv); repeat([h], nh); ['A']]
end

plan_directional(from::Char, to::Char) = plan_directional(directional_keypad[from], directional_keypad[to])
function plan_directional(from::CI, to::CI)
    Δi, Δj = (to - from).I
    v = Δi < 0 ? '^' : 'v'
    h = Δj < 0 ? '<' : '>'
    (v, abs(Δi)), (h, abs(Δj)), ('A', 1)
end

function plan_previous(moves, n)
    n == 0 && return length(moves)
    # @show moves, n
    e_moves = ['A', moves...]
    sum(zip(e_moves[1:end-1], e_moves[2:end])) do (a, b)
        count_moves(a, b, n)
    end
end


@memoize function count_moves(a, b, n)
    ps = plan_directional(a, b)
    prev_seq = move2seq(ps)
    prev_seq_2 = move2seq((ps[2], ps[1], ps[3]))
    # @show a, b, prev_seq
    min(plan_previous(prev_seq, n - 1), plan_previous(prev_seq_2, n - 1))
end

complexity(move) = mlength(move) * parse(Int64, join(move[1:end-1]))
function mlength(move)
    e_move = ['A', move...]
    sum(zip(e_move[1:end-1], e_move[2:end])) do (a, b)
        moves_1 = plan_numeric(a, b)
        moves_2 = (moves_1[2], moves_1[1], moves_1[3])
        min(plan_previous(move2seq(moves_1), 2), plan_previous(move2seq(moves_2), 2))
        # plan_previous(move2seq(moves_1), 2)
    end
end

using Test
mlength(x) = length(x |> cu_num |> cu |> cu)
@test mlength("029A") == 68
@test mlength("980A") == 60
@test mlength("179A") == 68
@test mlength("456A") == 64
@test mlength("379A") == 64

sum(complexity, data)

function compile_down(seq)
    pos = directional_keypad['A']
    out = Char[]
    for move in seq
        if move == 'A'
            push!(out, rdir_keypad[pos])
        else
            pos += moves[move]
        end
    end
    join(out)
end

compile_down("<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A")

function compile_up(seq)
    out = Char[]
    pos = directional_keypad['A']
    for key ∈ seq
        (v, nv), (h, nh), _ = plan_directional(pos, directional_keypad[key])
        foreach(_ -> push!(out, v), 1:nv)
        foreach(_ -> push!(out, h), 1:nh)
        push!(out, 'A')
        pos = directional_keypad[key]
    end
    join(out)
end

function cu_num(seq)
    out = Char[]
    pos = numeric_keypad['A']
    for key ∈ seq
        (v, nv), (h, nh), _ = plan_directional(pos, numeric_keypad[key])
        foreach(_ -> push!(out, h), 1:nh)
        foreach(_ -> push!(out, v), 1:nv)
        push!(out, 'A')
        pos = numeric_keypad[key]
    end
    join(out)
end

cu(x) = compile_up(x)
cd(x) = compile_down(x)