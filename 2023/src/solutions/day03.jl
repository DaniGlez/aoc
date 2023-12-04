const SIZE = 140
const CI = CartesianIndex
const directions = (CI(0, 1), CI(0, -1), CI(1, 0), CI(-1, 0),
    CI(1, 1), CI(1, -1), CI(-1, 1), CI(-1, -1))

is_inbounds(ci::CI{2}) = all(i -> i ∈ 1:SIZE, ci.I)
all_neighbours(ci::CI{2}) = map(Δ -> ci + Δ, directions)
is_a_symbol(c::Char) = c ∉ '0':'9' && c != '.'

function fetch_input(path="2023/inputs/input03.txt")
    map = Matrix{Char}(undef, (SIZE, SIZE))
    for (i, line) ∈ enumerate(eachline(path))
        map[i, :] .= collect(line)
    end
    map
end

function build_mask(schematic)
    mask = zeros(Bool, (SIZE, SIZE))
    for ci ∈ CartesianIndices(schematic)
        if is_a_symbol(schematic[ci])
            for neighbour ∈ all_neighbours(ci)
                is_inbounds(neighbour) || break
                mask[neighbour] = true
            end
        end
    end
    mask
end

function find_part_numbers(schematic)
    valid_numbers = Int64[]
    mask = build_mask(schematic)
    for i ∈ 1:SIZE
        process_line!(valid_numbers, (@view schematic[i, :]), @view mask[i, :])
    end
    valid_numbers
end

function process_line!(part_numbers, schematic_line, mask_line)
    i = 1
    while true
        j = findfirst(j -> schematic_line[j] ∈ '0':'9', i:SIZE)
        isnothing(j) && break
        i = j + i - 1
        k = findfirst(j -> schematic_line[j] ∉ '0':'9', i:SIZE)
        isnothing(k) ? (number_ending = SIZE) : (number_ending = k + i - 2)
        if any(mask_line[i:number_ending])
            push!(part_numbers, parse(Int64, String(schematic_line[i:number_ending])))
        end
        i = number_ending + 1
    end
end

fetch_input() |> find_part_numbers |> sum

# ------ Part 2 ------

const left = CI(0, -1)
const right = CI(0, 1)
const up = CI(-1, 0)
const down = CI(1, 0)

number_starts_at(schematic, ci) = schematic[ci] ∈ '0':'9' && (
    ci.I[2] == 1 || schematic[ci+left] ∉ '0':'9'
)

function parse_number(schematic, ci_start, ci_end)
    n = 0
    for ci ∈ ci_start:ci_end
        n *= 10
        n += schematic[ci] - '0'
        # println("$ci, $n")
    end
    n
end

function number_and_end(schematic, ci)
    max_length = (SIZE - ci.I[2]) + 1
    relpos_next_nondigit = findfirst(i -> schematic[ci+(i-1)*right] ∉ '0':'9', 1:max_length)
    number_length = isnothing(relpos_next_nondigit) ? max_length : relpos_next_nondigit - 1
    ci_end = ci + (number_length - 1) * right
    parse_number(schematic, ci, ci_end), ci_end
end

function find_gears(schematic)
    gears = Dict{CartesianIndex{2},Vector{Int64}}()
    for ci ∈ CartesianIndices(schematic)
        schematic[ci] == '*' && (gears[ci] = Int64[])
    end
    for ci ∈ CartesianIndices(schematic)
        if number_starts_at(schematic, ci)
            n, ci_end = number_and_end(schematic, ci)
            at_left = (ci + left) .+ (up, CI(0, 0), down)
            at_right = (ci_end + right) .+ (up, CI(0, 0), down)
            on_top = (ci:ci_end) .+ up
            on_bot = (ci:ci_end) .+ down
            for ij ∈ (at_left..., at_right..., on_top..., on_bot...)
                is_inbounds(ij) || continue
                (schematic[ij] == '*') && push!(gears[ij], n)
            end
        end
    end
    gears
end

sum(n -> length(n) == 2 ? prod(n) : 0, (fetch_input() |> find_gears |> values .|> unique))

using BenchmarkTools
s = fetch_input()
f(s) = sum(n -> length(n) == 2 ? prod(n) : 0, (s |> find_gears |> values .|> unique))
@benchmark f(s)