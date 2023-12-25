using JuMP
import HiGHS

conditional_push!(arr, elem) = elem ∈ arr || push!(arr, elem)
function parse_input(path="2023/inputs/input25.txt")
    components = Symbol[]
    wires = Tuple{Symbol,Symbol}[]
    for line ∈ eachline(path)
        component, rem_line = split(line, ": ")
        other_components = split(rem_line, ' ')
        sort!(other_components)
        conditional_push!(components, Symbol(component))
        for other ∈ other_components
            conditional_push!(components, Symbol(other))
            connection = sort([component, other])
            push!(wires, Symbol.(connection) |> Tuple)
        end
    end
    sort!(components)
    (components, wires)
end

function solve_p1(components_wires)
    components, wires = components_wires
    model = Model(HiGHS.Optimizer)
    # S[foo] represents foo being in one side or the other of the cut
    # W[(foo, bar)] == 1 <=> foo and bar are in different sides
    @variable(model, S[components], Bin)
    @variable(model, W[wires], Bin)
    for wire ∈ wires
        c₁, c₂ = wire
        @constraint(model, S[c₁] - S[c₂] <= W[wire])
        @constraint(model, S[c₂] - S[c₁] <= W[wire])
    end
    # We need components on both sides
    @constraint(model, sum(S) >= 1)
    @constraint(model, sum(S) <= length(components) - 1)

    # Trusting Evil Elf Eric
    @constraint(model, sum(W) == 3)
    optimize!(model)
    solution_summary(model), model
    n1 = sum(value, S) |> Int64
    n1 * (length(components) - n1)
end

parse_input() |> solve_p1 |> println