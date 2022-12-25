using Pipe

const CI₂ = CartesianIndex{2}

const up = CI₂(-1, 0)
const down = CI₂(1, 0)
const right = CI₂(0, 1)
const left = CI₂(0, -1)
const stay = CI₂(0, 0)
const dirs = (up, down, right, left, stay)

abstract type HDir end
abstract type VDir end
struct East <: HDir end
struct West <: HDir end
struct North <: VDir end
struct South <: VDir end

struct HStorm{D<:HDir}
    x0::Int64
end

struct VStorm{D<:VDir}
    y0::Int64
end

sign(::HStorm{D}) where {D} = sign(D())
sign(::VStorm{D}) where {D} = sign(D())
sign(::North) = -1
sign(::South) = 1
sign(::East) = 1
sign(::West) = -1

function parse_input(fpath="src/inputs/day24.txt")
    hstorms = Vector{Vector{HStorm}}()
    vstorms = Vector{Vector{VStorm}}()
    for (j, line) ∈ enumerate(eachline(fpath))
        if startswith(line, "#.#")
            for _ ∈ 1:(length(line)-2)
                push!(vstorms, Vector{VStorm}())
            end
            continue
        end
        if (line[2] == '#')
            return hstorms, vstorms, CI₂(0, 1), CI₂(j - 1, -1 + findfirst(c -> c == '.', line))
        end
        push!(hstorms, Vector{HStorm}())
        for (i, c) ∈ enumerate(line)
            (c == 'v') && push!(vstorms[i-1], VStorm{South}(j - 1))
            (c == '^') && push!(vstorms[i-1], VStorm{North}(j - 1))
            (c == '<') && push!(hstorms[j-1], HStorm{West}(i - 1))
            (c == '>') && push!(hstorms[j-1], HStorm{East}(i - 1))
        end
    end
end

parse_input()

struct SpaceTimePosition
    ci::CI₂
    t::Int64
end

x_pos(ci::CI₂) = ci.I[2]
x_pos(x::SpaceTimePosition) = x.ci.I[2]
y_pos(x::SpaceTimePosition) = x.ci.I[1]

using DataStructures
l∞(ci::CI₂) = abs(ci.I[1]) + abs(ci.I[2])
ttg_min(ci, goal) = l∞(goal - ci)

function next_moves(x::SpaceTimePosition, storm_check::F) where {F}
    candidates = @pipe dirs .|> SpaceTimePosition(x.ci + _, x.t + 1)
    filter(!storm_check, candidates)
end

function build_storm_checker(hstorms, vstorms, unblocked_nodes)
    h = length(hstorms)
    w = length(vstorms)
    function storm_check(x::SpaceTimePosition) # false = clear, true = blocked/unavailable
        x.ci ∈ unblocked_nodes && return false
        y_pos(x) < 1 && return true
        x_pos(x) < 1 && return true
        x_pos(x) > w && return true
        y_pos(x) > h && return true
        for hs ∈ hstorms[y_pos(x)]
            # TODO: invert calculation to move the current pos instead of the storm
            storm_x = mod1(hs.x0 + sign(hs) * x.t, w)
            storm_x == x_pos(x) && return true
        end
        for vs ∈ vstorms[x_pos(x)]
            storm_y = mod1(vs.y0 + sign(vs) * x.t, h)
            storm_y == y_pos(x) && return true
        end
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
        #println("$tmax $(length(reachable)) $(length(frontier)) $(current.t)")
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

function solve_p1(hstorms, vstorms, orig, dest)
    storm_check = build_storm_checker(hstorms, vstorms, (orig, dest))
    xt0 = SpaceTimePosition(orig, 0)
    minimum_time_path(storm_check, xt0, dest)
end

@pipe parse_input() |> solve_p1(_...)

function solve_p2(hstorms, vstorms, orig, dest)
    storm_check = build_storm_checker(hstorms, vstorms, (orig, dest))
    t0 = 0
    t1 = minimum_time_path(storm_check, SpaceTimePosition(orig, t0), dest)
    t2 = minimum_time_path(storm_check, SpaceTimePosition(dest, t1), orig)
    minimum_time_path(storm_check, SpaceTimePosition(orig, t2), dest)
end

@pipe parse_input() |> solve_p2(_...)
