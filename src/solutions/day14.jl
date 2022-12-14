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

# returns (retcode, final sand grain position)
function add_sand(A, sand_drop, stopping::Stopping)
    n, m = size(A)
    cur_pos = sand_drop
    (A[sand_drop] == EMPTY) || return (true, cur_pos)
    while true
        (stopping == p1) && (cur_pos.I[1] == n) && return (true, cur_pos)
        moved = false
        for dir ∈ (down, down_left, down_right)
            move = cur_pos + dir
            if checkbounds(Bool, A, move) && (A[move] == EMPTY)
                cur_pos = move
                moved = true
                break
            end
        end
        moved || return (false, cur_pos)
    end
end

function solve!(A_, stopping::Stopping)
    A = copy(A_)
    pos_rock = CI(1, 500)
    i = 0
    while true
        retcode, sand_pos = add_sand(A, pos_rock, stopping)
        A[sand_pos] = SAND
        retcode && return i
        i += 1
    end
end

solve_p1(A) = solve!(A, p1)
solve_p2(A) = solve!(A, p2)
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



# -------
using BenchmarkTools, DataStructures
@benchmark parse_input()
@benchmark solve_p1(parse_input())
@benchmark solve_p2(parse_input())

function solve_p2_dfs(A_)
    initial_grain = CI(1, 500)
    A = copy(A_)
    grains = Stack{CartesianIndex{2}}()
    occupied = 0
    push!(grains, initial_grain)
    while !isempty(grains)
        current = pop!(grains)
        occupied += 1
        A[current] = SAND
        for move ∈ (down, down_left, down_right)
            candidate = current + move
            if checkbounds(Bool, A, candidate) && (A[candidate] == EMPTY)
                push!(grains, candidate)
            end
        end
    end
    occupied
end

A = parse_input()
solve_p2_dfs(A) |> println
@benchmark solve_p2_dfs(A)

function solve_p2_bfs(A_)
    initial_grain = CI(1, 500)
    A = copy(A_)
    grains = Queue{CartesianIndex{2}}()
    occupied = 0
    enqueue!(grains, initial_grain)
    while !isempty(grains)
        current = dequeue!(grains)
        # With BFS we gotta check AFTER retrieving
        if checkbounds(Bool, A, current) && (A[current] == EMPTY)
            occupied += 1
            A[current] = SAND
            for move ∈ (down, down_left, down_right)
                candidate = current + move
                enqueue!(grains, candidate)
            end
        end

    end
    occupied
end

solve_p2_bfs(A)
@benchmark solve_p2_bfs(A)

# ------- fastest one -------
function solve_p2_vec(mask)
    n, m = size(mask)
    v = zeros(Bool, m)
    u = zeros(Bool, m)
    v[500] = true
    total_grains = 1
    wₗ, wₕ = 499, 501
    for i ∈ 1:(n-1)
        i₁ = i + 1
        mask_row = @view mask[i₁, :]
        for j ∈ wₗ:wₕ
            u[j] = (v[j-1] | v[j] | v[j+1]) & mask_row[j]
        end
        u[wₗ] && (wₗ -= 1)
        u[wₕ] && (wₕ += 1)
        total_grains += sum(u)
        u, v = v, u
    end
    total_grains
end

mask = Array{Bool}(parse_input() .+ 1)
solve_p2_vec(mask)
@benchmark solve_p2_vec($mask)