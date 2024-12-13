const CI = CartesianIndex
const CIs = CartesianIndices

function parse_button(text)
    chunks = split(text, '+')
    CI(parse(Int, split(chunks[2], ',')[1]), parse(Int, chunks[3]))
end

function parse_prize(text)
    chunks = split(text, '=')
    CI(parse(Int, split(chunks[2], ',')[1]), parse(Int, chunks[3]))
end

function parse_input(data="2024/inputs/day13.txt")
    lines = readlines(data)
    robots = Vector{NTuple{3,CI{2}}}()
    while length(lines) > 2
        A = popfirst!(lines) |> parse_button
        B = popfirst!(lines) |> parse_button
        prize = popfirst!(lines) |> parse_prize
        length(lines) > 0 && popfirst!(lines)
        push!(robots, (A, B, prize))
    end
    robots
end

using StaticArrays

function min_tokens(robot, offset=CI(0, 0))
    A, B, prize = robot
    AB = @SArray [A.I[1] B.I[1]; A.I[2] B.I[2]]
    prize_loc = prize + offset
    y = @SVector [prize_loc.I[1]; prize_loc.I[2]]
    token_costs = @SVector [3, 1]
    x = AB \ y
    wi = round.(Int, x)
    if wi[1] < 0 || wi[2] < 0
        0
    elseif wi[1] * A + wi[2] * B == prize_loc
        (all(>=(0), wi)) ? token_costs'wi : 0
    else
        0
    end
end

min_tokens_2(robot) = min_tokens(robot, CI(10000000000000, 10000000000000))

begin
    data = parse_input()
    sum(min_tokens, data) |> println
    sum(min_tokens_2, data) |> println
end