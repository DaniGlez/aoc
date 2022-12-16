using StaticArrays, Pipe

const VCode = Tuple{Char,Char}
struct Valve{N}
    flow_rate::Int64
    next_valves::NTuple{N,VCode}
end

const flow_re = r"flow rate=(\d+);"
vname(s) = collect(s[end-1:end]) |> Tuple
function pline(line)
    flow_rate = parse(Int64, match(flow_re, line).captures[1])
    println(line)
    valve_name = vname(line[7:8])
    other_valves = split(split(line, "to valv")[2], ", ") .|> vname
    valve_name => Valve(flow_rate, Tuple(vname.(other_valves)))
end
function parse_input(fpath="src/inputs/day16.txt")
    d = Dict{VCode,Valve}()
    for line ∈ eachline(fpath)
        push!(d, pline(line))
    end
    d
end

function previous_valves(valves, to_valve)
    Tuple(k for (k, v) ∈ valves if to_valve ∈ v.next_valves)
end

using JuMP
import DataFrames
import HiGHS

function solve_p1(valves)
    model = Model(HiGHS.Optimizer)
    vcodes = keys(valves)
    periods = 1:30
    # O[vcode, p] = opening valve vcode in period p
    # M[vcode, p] = moving to vcode in period p
    @variable(model, O[vcodes, periods], Bin)
    @variable(model, M[vcodes, periods], Bin)
    for k ∈ vcodes # no opening more than once
        @constraint(model, sum(O[k, :]) <= 1)
    end
    for p ∈ periods # just one action per period
        @constraint(model, sum(O[:, p]) + sum(M[:, p]) <= 1)
    end
    # only open V if you have moved to V in the previous period
    for (p1, p2) ∈ zip(periods[1:29], periods[2:30])
        for (c, v) ∈ valves
            @constraint(model, O[c, p2] <= M[c, p1])
        end
    end
    # only arrive to valve from valid valves
    for (p1, p2) ∈ zip(periods[1:29], periods[2:30])
        for (c, v) ∈ valves
            @constraint(model, M[c, p2] <= sum(M[pc, p1] + O[pc, p1]
                                               for pc ∈ previous_valves(valves, c)))
        end
    end
    # Initial conditions
    AA = vname("AA")
    @constraint(model, sum(M[c, 1] for c ∈ valves[AA].next_valves) == 1)
    # Opening values
    OV = Dict{VCode,SVector{30,Int64}}()
    factor = SVector{30}(29:-1:0)
    for (c, v) ∈ valves
        push!(OV, c => factor .* v.flow_rate)
    end
    @objective(model, Max, sum(OV[c]'O[c, :] for c ∈ keys(valves)))
    optimize!(model)
    for p ∈ 1:30
        if sum(value.(O[:, p])) > 0
            for c ∈ keys(valves)
                if value(O[c, p]) > 0
                    println("Period $p: opening valve $c")
                end
            end
        end
        if sum(value.(M[:, p])) > 0
            for c ∈ keys(valves)
                if value(M[c, p]) > 0
                    println("Period $p: moving to valve $c")
                end
            end
        end
    end
    solution_summary(model), model
end

vv = parse_input()
solve_p1(vv)
# Reading the solution from the solver output at this stage
