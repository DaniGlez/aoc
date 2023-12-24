using StaticArrays, LinearAlgebra

parse_line(line) = parse_triplet.(split(line, " @ ")) |> Tuple
parse_triplet(str) = parse.(Int64, split(str, ", ")) |> Tuple
parse_input(path="2023/inputs/input24.txt") = parse_line.(eachline(path))

const c_min, c_max = 200_000_000_000_000, 400_000_000_000_000

struct Interval{T}
    lb::T
    ub::T
end

Interval(ab) = Interval(ab...)
Base.in(x::Number, i::Interval) = (x ≥ i.lb) && (x ≤ i.ub)

function collide(a, b; xr=(c_min, c_max), yr=(c_min, c_max))
    x_a, v_a = a[1][1:2], a[2][1:2]
    x_b, v_b = b[1][1:2], b[2][1:2]
    V = @SMatrix[v_a[1] -v_b[1]; v_a[2] -v_b[2]]
    Δr = SVector(x_b .- x_a)
    t = V \ Δr
    minimum(t) > 0 || return nothing
    y_a = x_a .+ t[1] .* v_a
    (y_a[1] ∈ Interval(xr)) && (y_a[2] ∈ Interval(yr)) ? y_a : nothing
end

function collisions(particles)
    c = 0
    for (i, a) ∈ enumerate(particles)
        for b ∈ particles[1:i-1]
            if !isnothing(collide(a, b))
                c += 1
            end
        end
    end
    c
end

parse_input() |> collisions |> println

# ------ Part 2 ------

using NonlinearSolve

function expand_decision_vector(dv)
    tt = @SVector [dv[1], dv[2], dv[3]]
    x_star = @SVector [dv[4], dv[5], dv[6]]
    v_star = @SVector [dv[7], dv[8], dv[9]]
    tt, x_star, v_star
end

function get_intersection_times(a, b, c)
    x_a, v_a = SVector.(a)
    x_b, v_b = SVector.(b)
    x_c, v_c = SVector.(c)
    scaling = 1
    function f(u, _)
        tt, x_star, v_star = expand_decision_vector(u)
        Δa = (x_star - scaling * x_a + tt[1] * (v_star - v_a))
        Δb = (x_star - scaling * x_b + tt[2] * (v_star - v_b))
        Δc = (x_star - scaling * x_c + tt[3] * (v_star - v_c))
        vcat(Δa, Δb, Δc)
    end
    u0 = SVector{9}(zeros(9))
    sol = solve(NonlinearProblem(f, u0))
    tt, x_star, v_star = expand_decision_vector(sol.u)
    # v_star has the best relative precision since it has the lowest magnitude
    # We believe in v⋆
    v_star = round.(Int64, v_star)
    refine_solution(a, b, c, tt ./ scaling, x_star ./ scaling, v_star)
end

L¹(x) = sum(abs.(x))

function int_error(xv, t, x_star, v_star)
    x, v = SVector.(xv)
    x - x_star + (v - v_star) * t
end

function adjust_t(xv, t0, x_star, v_star)
    t = t0
    err = int_error(xv, t, x_star, v_star) |> L¹
    while true
        err_next = int_error(xv, t + 1, x_star, v_star) |> L¹
        err_next >= err && return t
        err = err_next
        t += 1
    end
    while true
        err_prev = int_error(xv, t - 1, x_star, v_star) |> L¹
        err_prev >= err && return t
        err = err_prev
        t -= 1
    end
end

function refine_solution(a, b, c, t_abc, x_star_0, v_star)
    tt = round.(Int64, t_abc)
    x_star = round.(Int64, x_star_0)
    abc = (a, b, c)
    err = sum(L¹, int_error(xv, t, x_star, v_star) for (xv, t) ∈ zip(abc, tt))
    while err > 0
        tt = map(((xv, t),) -> adjust_t(xv, t, x_star, v_star), zip(abc, tt))
        new_err = sum(L¹, int_error(xv, t, x_star, v_star) for (xv, t) ∈ zip(abc, tt))
        new_err <= err || error("")
        err = new_err
        avg_error = sum(((xv, t),) -> int_error(xv, t, x_star, v_star), zip(abc, tt)) / 3
        x_star += round.(Int64, avg_error)
    end
    sum(x_star)
end

function solve_p2(particles)
    get_intersection_times(particles[1:3]...)
end

parse_input() |> solve_p2 |> println

# Alternative with Optim

# function get_intersection_times(a, b, c)
#     x_a, v_a = SVector.(a)
#     x_b, v_b = SVector.(b)
#     x_c, v_c = SVector.(c)
#     scaling = 1e6 / (sum(x_a) + sum(x_b) + sum(x_c))
#     function obj(dv)
#         tt, x_star, v_star = expand_decision_vector(dv)
#         Δa = (x_star - scaling * x_a + tt[1] * (v_star - v_a))
#         Δb = (x_star - scaling * x_b + tt[2] * (v_star - v_b))
#         Δc = (x_star - scaling * x_c + tt[3] * (v_star - v_c))
#         (Δa'Δa + Δb'Δb + Δc'Δc)
#     end
#     sol = optimize(obj, zeros(9), LBFGS())
#     tt, x_star, v_star = expand_decision_vector(sol.minimizer)
#     v_star = round.(Int64, v_star) # v_star has the best relative precision
#     refine_solution(a, b, c, tt ./ scaling, x_star ./ scaling, v_star)
# end