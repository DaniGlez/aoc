pInt(x) = parse(Int, x)
function parse_ingredients(filename)
    ranges = NTuple{2,Int64}[]
    ingredients = Int64[]
    parsing_ranges = true
    for line ∈ eachline(filename)
        if parsing_ranges
            if isempty(line)
                parsing_ranges = false
                continue
            end
            chunks = Tuple(split(line, '-'))
            push!(ranges, pInt.(chunks))
        else
            push!(ingredients, pInt(line))
        end
    end
    return ranges, ingredients
end

begin
    ranges, ingredients = parse_ingredients("2025/inputs/day05.txt")
    count(ingredients) do i
        any(r -> r[1] ≤ i ≤ r[2], ranges)
    end |> println
end

function sranges(ranges)
    sum(ranges) do r
        r[2] - r[1] + 1
    end
end

begin
    ranges, _ = parse_ingredients("2025/inputs/day05.txt")
    sort!(ranges, by=r -> r[1])
    acc = 0
    while !isempty(ranges)
        l, h = pop!(ranges)
        isempty(ranges) && @goto add_length
        pl, ph = last(ranges)
        if l ≤ ph
            ranges[end] = (ranges[end][1], max(h, ph))
        else
            @label add_length
            acc += h - l + 1
        end
    end
    println(acc)
end