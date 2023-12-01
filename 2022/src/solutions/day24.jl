using Pipe

const CI₂ = CartesianIndex{2}

const up = CI₂(-1, 0)
const down = CI₂(1, 0)
const right = CI₂(0, 1)
const left = CI₂(0, -1)
const stay = CI₂(0, 0)
const dirs = (up, down, right, left, stay)

function parse_input(fpath="src/inputs/day24.txt")
    cmatrix = hcat((readlines(fpath) .|> collect)...) |> permutedims
    x_dest = findfirst(c -> c == '.', cmatrix[end, 2:end])
    y_dest = size(cmatrix)[1] - 1
    cmatrix, CI₂(y_dest, x_dest)
end

struct SpaceTimePosition
    ci::CI₂
    t::Int64
end

x_pos(ci::CI₂) = ci.I[2]
x_pos(x::SpaceTimePosition) = x.ci.I[2]
y_pos(x::SpaceTimePosition) = x.ci.I[1]

using DataStructures
l₁(ci::CI₂) = abs(ci.I[1]) + abs(ci.I[2])
ttg_min(ci, goal) = l₁(goal - ci)

function next_moves(x::SpaceTimePosition, storm_check::F) where {F}
    candidates = @pipe dirs .|> SpaceTimePosition(x.ci + _, x.t + 1)
    filter(!storm_check, candidates)
end

function build_storm_checker(cmatrix, unblocked_nodes)
    h, w = size(cmatrix) .- 2
    A = @view cmatrix[2:end-1, 2:end-1]
    function storm_check(st::SpaceTimePosition) # false = clear, true = blocked/unavailable
        st.ci ∈ unblocked_nodes && return false
        x = x_pos(st)
        y = y_pos(st)
        x ∉ 1:w && return true
        y ∉ 1:h && return true
        x_west = mod1(x + st.t, w)
        A[y, x_west] == '<' && return true
        x_east = mod1(x - st.t, w)
        A[y, x_east] == '>' && return true
        y_north = mod1(y + st.t, h)
        A[y_north, x] == '^' && return true
        y_south = mod1(y - st.t, h)
        A[y_south, x] == 'v' && return true
        false
    end
    storm_check
end

function minimum_time_path(storm_check, xt_orig, dest)
    reachable = Set{SpaceTimePosition}()
    frontier = PriorityQueue{SpaceTimePosition,Int64}()
    enqueue!(frontier, xt_orig => 0)
    tmax = -1
    while !isempty(frontier)
        current = dequeue!(frontier)
        (tmax != -1) && (ttg_min(current.ci, dest) + current.t >= tmax) && continue
        for s ∈ next_moves(current, storm_check)
            (tmax != -1) && (ttg_min(s.ci, dest) + s.t >= tmax) && continue
            s ∈ reachable && continue
            push!(reachable, s)
            tmin_s = s.t + ttg_min(s.ci, dest)
            #enqueue!(frontier, s => s.t) BFS (~2x slower)
            enqueue!(frontier, s => tmin_s)
            if s.ci == dest
                (tmax == -1) && (tmax = s.t)
                tmax = min(tmax, s.t)
            end
        end
    end
    tmax
end

function solve_p1(cmatrix, dest)
    orig = CI₂(0, 1)
    storm_check = build_storm_checker(cmatrix, (orig, dest))
    xt0 = SpaceTimePosition(orig, 0)
    minimum_time_path(storm_check, xt0, dest)
end

@pipe parse_input() |> solve_p1(_...)

function solve_p2(cmatrix, dest)
    orig = CI₂(0, 1)
    storm_check = build_storm_checker(cmatrix, (orig, dest))
    t1 = minimum_time_path(storm_check, SpaceTimePosition(orig, 0), dest)
    t2 = minimum_time_path(storm_check, SpaceTimePosition(dest, t1), orig)
    minimum_time_path(storm_check, SpaceTimePosition(orig, t2), dest)
end

@pipe parse_input() |> solve_p2(_...)
