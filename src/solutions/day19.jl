using JuMP, Pipe

struct Blueprint
    id::Int64
    ore_cost_ore::Int64
    clay_cost_ore::Int64
    obsidian_cost_ore::Int64
    obsidian_cost_clay::Int64
    geode_cost_ore::Int64
    geode_cost_obsidian::Int64
end

pInt(x) = parse(Int64, x)
const re = r"Blueprint (\d+): Each ore robot costs (\d+) ore. Each clay robot costs (\d+) ore. Each obsidian robot costs (\d+) ore and (\d+) clay. Each geode robot costs (\d+) ore and (\d+) obsidian."
parse_bp(line) = Blueprint((match(re, line).captures .|> pInt)...)
parse_input(fpath="src/inputs/day19.txt") = readlines(fpath) .|> parse_bp

import HiGHS
function max_geodes(bp::Blueprint, periods=24)
    model = Model(HiGHS.Optimizer)
    T = 1:periods+1 # t ∈ T represents the values between periods so there's one additional point
    T₋ = 1:periods
    T₊ = 2:periods+1
    M = (:ore, :clay, :obsidian, :geode)
    @variable(model, 0 <= robots[M, T], integer = true)
    @variable(model, 0 <= minerals[M, T], integer = true)
    @variable(model, 0 <= fabrication[M, T₋], integer = true)
    for m ∈ M, (t₋, t₊) ∈ zip(T₋, T₊)
        @constraint(model, robots[m, t₊] == robots[m, t₋] + fabrication[m, t₋])
    end
    for t ∈ T₋
        @constraint(model, sum(fabrication[:, t]) <= 1)
    end
    for (t₋, t₊) ∈ zip(T₋, T₊)
        # production + previous stock = consumption + subsequent stock
        @constraint(model, minerals[:ore, t₋] + robots[:ore, t₋] == (minerals[:ore, t₊] +
                                                                     bp.ore_cost_ore * fabrication[:ore, t₋] +
                                                                     bp.clay_cost_ore * fabrication[:clay, t₋] +
                                                                     bp.obsidian_cost_ore * fabrication[:obsidian, t₋] +
                                                                     bp.geode_cost_ore * fabrication[:geode, t₋]
        ))
        @constraint(model, minerals[:clay, t₋] + robots[:clay, t₋] == (minerals[:clay, t₊] +
                                                                       bp.obsidian_cost_clay * fabrication[:obsidian, t₋]))
        @constraint(model, minerals[:obsidian, t₋] + robots[:obsidian, t₋] == (minerals[:obsidian, t₊] +
                                                                               bp.geode_cost_obsidian * fabrication[:geode, t₋]))
        @constraint(model, minerals[:geode, t₋] + robots[:geode, t₋] == (minerals[:geode, t₊]))
        # fabricate only with the available materials at the beginning of the period
        @constraint(model, minerals[:ore, t₋] >= (bp.ore_cost_ore * fabrication[:ore, t₋] +
                                                  bp.clay_cost_ore * fabrication[:clay, t₋] +
                                                  bp.obsidian_cost_ore * fabrication[:obsidian, t₋] +
                                                  bp.geode_cost_ore * fabrication[:geode, t₋]
        ))
        @constraint(model, minerals[:clay, t₋] >= bp.obsidian_cost_clay * fabrication[:obsidian, t₋])
        @constraint(model, minerals[:obsidian, t₋] >= bp.geode_cost_obsidian * fabrication[:geode, t₋])
    end
    for m ∈ M
        if m == :ore
            @constraint(model, robots[m, 1] == 1)
            @constraint(model, minerals[m, 1] == 0)
        else
            @constraint(model, robots[m, 1] == 0)
            @constraint(model, minerals[m, 1] == 0)
        end
    end
    @objective(model, Max, minerals[:geode, periods+1])
    optimize!(model)
    round(Int64, objective_value(model))
end

quality(bp::Blueprint) = max_geodes(bp) * bp.id
solve_p1(blueprints) = quality.(blueprints) |> sum
p = parse_input()
parse_input() |> solve_p1 |> println

solve_p2(blueprints) = @pipe blueprints[1:3] .|> max_geodes(_, 32) |> prod
parse_input() |> solve_p2 |> println

