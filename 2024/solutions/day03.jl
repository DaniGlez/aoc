function sum_muls(text)
    sum(eachmatch(r"mul\((\d+),(\d+)\)", text)) do match
        parse(Int, match.captures[1]) * parse(Int, match.captures[2])
    end
end

read("2024/inputs/day03.txt", String) |> sum_muls |> println

sum(split(text, "do()")) do chunk
    valid_instructions = split(chunk, "don't()") |> first
    sum_muls(valid_instructions)
end |> println