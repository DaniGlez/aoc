const EMPTY = 0
const ROCK = -1
const SAND = 1
const CI = CartesianIndex
const down = CartesianIndex(1, 0)
const down_left = CartesianIndex(1, -1)
const down_right = CartesianIndex(1, 1)
@enum Stopping p1 p2

pInt(x) = parse(Int64, x)
function str2ci(s)
    a, b = split(s, ',') .|> pInt
    CI(b + 1, a)
end

clamp2unit(x) = clamp(x, -1, 1)
function good_range(a, b)
    if (b.I[1] < a.I[1]) || (b.I[2] < a.I[2])
        return b:a
    end
    a:b
end

function parse_input(fpath="src/inputs/day14.txt")
    A = zeros(Int8, (200, 1002))
    for line ∈ eachline(fpath)
        points = split(strip(line), " -> ") .|> str2ci
        for (start, endpoint) ∈ zip(points[begin:end-1], points[begin+1:end])
            r = good_range(start, endpoint)
            A[r] .= ROCK
        end
    end
    while sum(A[(end-1):end, :]) == 0
        A = A[begin:end-1, :]
    end
    A
end

function move_sand!(A, current, Δ)
    A[current] = EMPTY
    A[current+Δ] = SAND
    current + Δ
end

function add_sand!(A, sand_drop, stopping::Stopping)
    n, m = size(A)
    (A[sand_drop] == EMPTY) || return true
    A[sand_drop] = SAND
    cur_pos = sand_drop
    while true
        (stopping == p1) && (cur_pos.I[1] == n) && return true
        moved = false
        for dir ∈ (down, down_left, down_right)
            move = cur_pos + dir
            if checkbounds(Bool, A, move) && (A[move] == EMPTY)
                cur_pos = move_sand!(A, cur_pos, dir)
                moved = true
                break
            end
        end
        moved || return false
    end
end

function solve(A, stopping::Stopping)
    pos_rock = CI(1, 500)
    i = 0
    while true
        add_sand!(A, pos_rock, stopping) && return i
        i += 1
    end
end

solve_p1(A) = solve(A, p1)
solve_p2(A) = solve(A, p2)
parse_input() |> solve_p1
parse_input() |> solve_p2


# ---------- plotting ------------
function status2char(status)
    status == EMPTY && return '.'
    status == ROCK && return '#'
    status == SAND && return 'o'
    error("")
end

function plot(A, offset=490)
    for row ∈ eachrow(A)
        println(row[offset:end] .|> status2char |> join)
    end
end
