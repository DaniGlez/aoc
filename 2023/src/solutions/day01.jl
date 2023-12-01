using StaticArrays
using Base: @nexprs

# ------ Part 1 -------
function line2code_p1(s::AbstractString)
    digits = collect(s) |> filter(c -> c ∈ '0':'9') .|> c -> c - '0'
    10first(digits) + last(digits)
end

sum(line2code_p1, eachline("2023/inputs/input01.txt")) |> println

# ------ Part 2 -------
const digit_names = ("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
const digit_names_tot = map(Tuple ∘ collect, digit_names)

# Ugly af but a single pass over each line
function line2code_p2(s::AbstractString)
    first_value, last_value = -1, -1
    progress = @MArray zeros(Int8, 9)
    progress .= 1
    for c ∈ s
        if c ∈ '0':'9'
            digit = c - '0'
            first_value == -1 && (first_value = digit)
            last_value = digit
            progress .= 1
        else
            @nexprs 9 d -> begin
                # for (d, name) ∈ enumerate(digit_names_tot)
                name = digit_names_tot[d]
                if c == name[progress[d]]
                    progress[d] += 1
                else
                    name[1] == c ? (progress[d] = 2) : (progress[d] = 1)
                end
                if progress[d] > length(name)
                    first_value == -1 && (first_value = d)
                    last_value = d
                    progress[d] = 1
                end
            end
        end
    end
    10first_value + last_value
end

sum(line2code_p2, eachline("2023/inputs/input01.txt")) |> println

# ------ Debug -------
for line ∈ eachline("2023/inputs/input01.txt")
    println(line, " -> ", line2code_p2(line))
end
